import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:server_core/server_core.dart' as server_core;
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:server_jellyfin/server_jellyfin.dart' as server_jellyfin;
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/cast/cast.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/pages/mining/mining_mode_page.dart';
import 'package:yuuna/utils.dart';

/// Media source that integrates Jellyfin media server.
///
/// Fully migrated to Moonfin architecture — uses [JellyfinMediaServerClient]
/// and abstract APIs instead of the legacy [JellyfinClient].
class PlayerJellyfinSource extends PlayerMediaSource {
  PlayerJellyfinSource._privateConstructor()
      : super(
          uniqueKey: 'player_jellyfin',
          sourceName: 'Jellyfin',
          description: 'Stream from a Jellyfin media server and mine subtitles.',
          icon: Icons.live_tv,
          implementsSearch: true,
          implementsHistory: true,
        );

  static PlayerJellyfinSource get instance => _instance;
  static final PlayerJellyfinSource _instance = PlayerJellyfinSource._privateConstructor();

  server_jellyfin.JellyfinMediaServerClient? _client;

  final Map<String, List<server_core.MediaItem>> _browseCache = {};
  final Map<String, server_core.MediaItem> _itemCache = {};
  final Map<String, String> _subtitleCache = {};
  bool _isDiscovering = false;

  bool get isLoggedIn => _client?.accessToken != null && _client?.userId != null;
  server_jellyfin.JellyfinMediaServerClient? get serverClient => _client;

  void setServerClient(server_jellyfin.JellyfinMediaServerClient? client) {
    _client?.dispose();
    _client = client;
  }

  // ─── Connection Management ─────────────────────────────────────────────

  /// Fallback URL used when the primary server is unreachable via WiFi
  /// (e.g., router wireless isolation). Requires `adb reverse tcp:8096 tcp:8096`.
  static const _fallbackUrl = 'http://127.0.0.1:8096';

  /// Tries a connection with the given [url]. If it fails with a network error,
  /// automatically falls back to [_fallbackUrl] (adb reverse tunnel).
  Future<bool> _tryRestore(String url, String token, String uid) async {
    _client = server_jellyfin.JellyfinMediaServerClient(
      baseUrl: url,
      deviceInfo: _deviceInfo,
      accessToken: token,
      userId: uid,
    );
    try {
      await _client!.itemsApi.getViews();
      debugPrint('[Jellyfin] ✅ Session restored to $url');
      return true;
    } on SocketException {
      debugPrint('[Jellyfin] ⚠️ Network unreachable: $url');
      _client = null;
      return false;
    } catch (e) {
      debugPrint('[Jellyfin] ❌ Session restore failed: $e');
      _client = null;
      return false;
    }
  }

  Future<bool> restoreSession() async {
    // Ensure the source is initialised before accessing preferences.
    await initialise();

    final url = getPreference<String?>(key: 'jellyfin_server_url', defaultValue: null);
    final token = getPreference<String?>(key: 'jellyfin_access_token', defaultValue: null);
    final uid = getPreference<String?>(key: 'jellyfin_user_id', defaultValue: null);
    debugPrint('[Jellyfin] restoreSession: url=$url token=${token != null ? "yes" : "no"} uid=$uid');
    if (url == null || token == null || uid == null) {
      debugPrint('[Jellyfin] restoreSession: missing credentials');
      return false;
    }

    // Try primary URL first.
    if (await _tryRestore(url, token, uid)) return true;

    // If primary failed with network error and it's a local IP, try adb tunnel.
    if (url != _fallbackUrl) {
      debugPrint('[Jellyfin] 🔄 Falling back to adb tunnel: $_fallbackUrl');
      return await _tryRestore(_fallbackUrl, token, uid);
    }

    return false;
  }

  Future<bool> _tryConnect(String url, String username, String password) async {
    _client = server_jellyfin.JellyfinMediaServerClient(
      baseUrl: url,
      deviceInfo: _deviceInfo,
    );
    try {
      final r = await _client!.authApi.authenticateByName(username, password);
      debugPrint('[Jellyfin] ✅ Auth success: userId=${r.userId}');
      _client!.setCredentials(accessToken: r.accessToken, userId: r.userId);
      await setPreference<String?>(key: 'jellyfin_server_url', value: url);
      await setPreference<String?>(key: 'jellyfin_access_token', value: r.accessToken);
      await setPreference<String?>(key: 'jellyfin_user_id', value: r.userId);
      return true;
    } on SocketException {
      debugPrint('[Jellyfin] ⚠️ Network unreachable: $url');
      _client = null;
      return false;
    } catch (e) {
      debugPrint('[Jellyfin] ❌ Auth failed: $e');
      _client = null;
      rethrow;
    }
  }

  Future<bool> connectToServer(String url, String username, String password) async {
    debugPrint('[Jellyfin] connectToServer: $url ($username)');

    // Try primary URL first.
    if (await _tryConnect(url, username, password)) return true;

    // If primary failed with network error and it's a local IP, try adb tunnel.
    if (url != _fallbackUrl) {
      debugPrint('[Jellyfin] 🔄 Falling back to adb tunnel: $_fallbackUrl');
      return await _tryConnect(_fallbackUrl, username, password);
    }

    return false;
  }

  Future<void> disconnect() async {
    try { await _client?.authApi.logout(); } catch (_) {}
    _client?.dispose();
    _client = null;
    _browseCache.clear();
    _itemCache.clear();
    _subtitleCache.clear();
    await deletePreference(key: 'jellyfin_server_url');
    await deletePreference(key: 'jellyfin_access_token');
    await deletePreference(key: 'jellyfin_user_id');
  }

  server_core.DeviceInfo get _deviceInfo => server_core.DeviceInfo(
    deviceId: 'yuuna-${DateTime.now().millisecondsSinceEpoch}',
    deviceName: 'Yuuna',
    clientName: 'Yuuna',
    clientVersion: '2.9.0',
  );

  server_jellyfin.JellyfinMediaServerClient get _c {
    if (_client == null) throw Exception('Not connected to Jellyfin.');
    return _client!;
  }

  // ─── Library Browsing ──────────────────────────────────────────────────

  Future<List<server_core.MediaItem>> getViews() => _c.itemsApi.getViews();

  Future<List<server_core.MediaItem>> getItems(
    String parentId, {
    String? parentType,
    String? seriesId,
  }) async {
    final cacheKey = '$parentId-$parentType-$seriesId';
    if (_browseCache.containsKey(cacheKey)) {
      debugPrint('[Jellyfin] getItems CACHE HIT: $cacheKey (${_browseCache[cacheKey]!.length} items)');
      return _browseCache[cacheKey]!;
    }

    debugPrint('[Jellyfin] getItems: parentId=$parentId parentType=$parentType seriesId=$seriesId');

    List<server_core.MediaItem> items;
    final pt = parentType?.toLowerCase();
    if ((pt == 'series') && seriesId != null) {
      debugPrint('[Jellyfin] → getSeasons(seriesId=$seriesId)');
      items = await _c.itemsApi.getSeasons(seriesId);
    } else if ((pt == 'season') && seriesId != null) {
      debugPrint('[Jellyfin] → getEpisodes(seriesId=$seriesId, seasonId=$parentId)');
      items = await _c.itemsApi.getEpisodes(seriesId, parentId);
    } else {
      debugPrint('[Jellyfin] → getItems(parentId=$parentId, recursive=${parentType == null})');
      items = await _c.itemsApi.getItems(parentId, recursive: parentType == null);
    }
    debugPrint('[Jellyfin] getItems RESULT: ${items.length} items');
    for (final i in items) {
      debugPrint('[Jellyfin]   - "${i.name}" type=${i.type} isFolder=${i.isFolder}');
    }
    _browseCache[cacheKey] = items;
    for (final i in items) { _itemCache[i.id] = i; }
    return items;
  }

  Future<server_core.MediaItem> getItemDetails(String itemId) async {
    if (_itemCache.containsKey(itemId)) return _itemCache[itemId]!;
    final item = await _c.itemsApi.getItem(itemId);
    _itemCache[itemId] = item;
    return item;
  }

  // ─── MediaItem Factory ─────────────────────────────────────────────────

  MediaItem createMediaItem(server_core.MediaItem item) {
    final msId = item.mediaSources.isNotEmpty ? item.mediaSources.first.id : '';
    return MediaItem(
      title: item.name,
      mediaIdentifier: item.id,
      mediaSourceIdentifier: uniqueKey,
      mediaTypeIdentifier: mediaType.uniqueKey,
      position: item.userData['PlaybackPositionTicks'] != null
          ? (item.userData['PlaybackPositionTicks'] as int) ~/ 10000000
          : 0,
      duration: item.runTimeTicks != null ? item.runTimeTicks! ~/ 10000000 : 0,
      extra: jsonEncode({
        'mediaSourceId': msId,
        'serverUrl': _client?.baseUrl ?? '',
        'overview': item.overview ?? '',
        'seriesName': item.seriesName ?? '',
        'seasonName': item.seasonName ?? '',
        'episodeLabel': item.indexNumber != null && item.parentIndexNumber != null
            ? 'S${item.parentIndexNumber.toString().padLeft(2, '0')}E${item.indexNumber.toString().padLeft(2, '0')}'
            : '',
        'itemType': item.type ?? '',
        'productionYear': item.productionYear?.toString() ?? '',
      }),
      canEdit: false,
      canDelete: false,
      imageUrl: _buildImageUrl(item),
    );
  }

  String? _buildImageUrl(server_core.MediaItem item) {
    if (item.imageTags.isEmpty) return null;
    final tag = item.imageTags['Primary'] ?? item.imageTags.values.first;
    if (_client != null) return _client!.imageApi.getImageUrl(item.id, tag);
    return '${_client?.baseUrl ?? ''}/Items/${item.id}/Images/Primary?tag=$tag&quality=90';
  }

  // ─── Player ────────────────────────────────────────────────────────────

  @override
  BasePage buildHistoryPage({MediaItem? item}) => const _JellyfinLibraryWrapperPage();

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) =>
      PlayerSourcePage(item: item, source: this, useHistory: implementsHistory);

  @override
  Future<UniversalPlayerController> preparePlayerController({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    final extra = jsonDecode(item.extra ?? '{}') as Map<String, dynamic>;
    var msId = extra['mediaSourceId'] as String? ?? '';

    if (msId.isEmpty) {
      final jItem = await _c.itemsApi.getItem(item.mediaIdentifier);
      _itemCache[item.mediaIdentifier] = jItem;
      msId = jItem.mediaSources.isNotEmpty ? jItem.mediaSources.first.id : '';
    }
    if (msId.isEmpty) throw Exception('No media source available.');

    // Use VLC for Jellyfin streaming (same backend as other media sources).
    final streamUrl = _c.playbackApi.getStreamUrl(item.mediaIdentifier, msId);

    // Cap start time to avoid seeking to the very end (e.g. if Jellyfin
    // reports the item as fully watched via PlaybackPositionTicks = RunTimeTicks).
    final duration = item.duration > 0 ? item.duration : 0;
    final startTime = item.position < duration - 10 ? item.position : 0;

    final vlc = VlcPlayerController.network(
      streamUrl,
      hwAcc: appModel.playerHardwareAcceleration ? HwAcc.auto : HwAcc.disabled,
      allowBackgroundPlayback: appModel.playerBackgroundPlay,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          '--start-time=$startTime',
          VlcAdvancedOptions.networkCaching(20000),
        ]),
      ),
    );
    return UniversalPlayerController.vlc(vlc);
  }

  @override
  Future<List<SubtitleItem>> prepareSubtitles({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    final extra = jsonDecode(item.extra ?? '{}') as Map<String, dynamic>;
    var msId = extra['mediaSourceId'] as String? ?? '';

    try {
      final jItem = await getItemDetails(item.mediaIdentifier);
      debugPrint('[Jellyfin] prepareSubtitles: item=${item.mediaIdentifier}, '
          'total streams=${jItem.mediaStreams.length}, msId=$msId');

      final subtitleStreams = jItem.mediaStreams
          .where((s) => s.type == 'Subtitle')
          .toList();
      debugPrint('[Jellyfin] Found ${subtitleStreams.length} subtitle streams');

      if (subtitleStreams.isEmpty) {
        debugPrint('[Jellyfin] No subtitle streams — returning empty.');
        return [];
      }
      if (msId.isEmpty) msId = jItem.mediaSources.isNotEmpty ? jItem.mediaSources.first.id : '';
      if (msId.isEmpty) {
        debugPrint('[Jellyfin] No media source ID — returning empty.');
        return [];
      }

      final service = SubtitleService(
        (iid, sid, idx) => _c.playbackApi.getSubtitleContent(iid, sid, idx),
      );
      return service.loadSubtitles(
        itemId: item.mediaIdentifier,
        subtitleStreams: subtitleStreams.map((s) => SubtitleStreamMeta(
              index: s.index,
              codec: s.codec,
              displayTitle: s.displayTitle,
              language: s.language,
              isExternal: s.isExternal ?? false,
              deliveryUrl: s.deliveryUrl,
            )).toList(),
        mediaSourceId: msId,
      );
    } catch (e) {
      debugPrint('[Jellyfin] ❌ prepareSubtitles exception: $e');
      return [];
    }
  }

  // ─── Search ────────────────────────────────────────────────────────────

  @override
  Future<List<MediaItem>?> searchMediaItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) async {
    if (!isLoggedIn) return null;
    try {
      final views = await getViews();
      final allItems = <server_core.MediaItem>[];
      for (final v in views) {
        if (v.isFolder == true) {
          allItems.addAll(await _c.itemsApi.getItems(v.id,
            recursive: true,
            includeItemTypes: ['Movie', 'Episode'],
            startIndex: pageKey * 20,
            limit: 20,
          ));
        }
      }
      final q = searchTerm.toLowerCase();
      return allItems.where((i) =>
        i.name.toLowerCase().contains(q) ||
        (i.seriesName?.toLowerCase().contains(q) ?? false) ||
        (i.originalTitle?.toLowerCase().contains(q) ?? false) ||
        (i.overview?.toLowerCase().contains(q) ?? false)
      ).map(createMediaItem).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Search Bar ────────────────────────────────────────────────────────

  @override
  BaseMediaSearchBar? buildBar() => const JellyfinMediaSearchBar();

  // ─── Cast + Mine ───────────────────────────────────────────────────────

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      FloatingSearchBarAction(
        child: JidoujishoIconButton(
          size: Theme.of(context).textTheme.titleLarge?.fontSize,
          tooltip: 'Jellyfin Settings',
          icon: Icons.settings,
          onTap: () => showDialog(
            context: context,
            builder: (context) => const JellyfinSettingsDialogPage(),
          ),
        ),
      ),
      if (isLoggedIn && appModel.currentMediaItem != null)
        FloatingSearchBarAction(
          child: JidoujishoIconButton(
            size: Theme.of(context).textTheme.titleLarge?.fontSize,
            tooltip: 'Cast + Mine',
            icon: Icons.cast,
            onTap: () async {
              final mi = appModel.currentMediaItem;
              if (mi != null) await launchMiningMode(context, ref, appModel, mi);
            },
          ),
        ),
    ];
  }

  Future<void> launchMiningMode(
    BuildContext context,
    WidgetRef ref,
    AppModel appModel,
    MediaItem item,
  ) async {
    debugPrint('[Cast+Mine] Starting cast flow for: ${item.title}');
    if (_isDiscovering) {
      debugPrint('[Cast+Mine] ⚠️ Already discovering, ignoring duplicate click.');
      return;
    }
    _isDiscovering = true;

    try {
      // ─── Phase 1: Show picker immediately + start discovery in background ───
      // This mirrors YouTube's Cast dialog: opens instantly, devices appear
      // as they're found. No more 8-second blank wait.

      debugPrint('[Cast+Mine] Opening picker + starting discovery...');

      // Stream controller for device updates — survives refresh.
      // Only closed when the picker is dismissed, not on discovery completion.
      final deviceController = StreamController<List<CastTarget>>.broadcast();
      StreamSubscription<List<CastTarget>>? discoverySub;

      void startDiscovery({bool clearCache = false}) {
        if (clearCache) {
          DeviceDiscovery.clearCache();
        }
        // Cancel previous discovery so we don't have two running at once.
        discoverySub?.cancel();
        final d = DeviceDiscovery(_c.sessionApi);
        discoverySub = d.discoverIncremental().listen(
          (devices) {
            if (!deviceController.isClosed) deviceController.add(devices);
          },
          // NO onDone close — the controller stays open for refresh.
        );
      }

      startDiscovery();

      // Fetch item metadata concurrently (needed after selection).
      final jItemFuture = _c.itemsApi.getItem(item.mediaIdentifier);

      if (!context.mounted) { _isDiscovering = false; return; }

      // Show picker immediately with cached devices + live stream.
      // Fully draggable: down to dismiss, up to expand. Refresh button re-scans.
      final target = await DevicePicker.show(
        context: context,
        initialDevices: DeviceDiscovery.cachedDevices,
        deviceStream: deviceController.stream,
        onRefresh: () => startDiscovery(clearCache: true),
      );
      _isDiscovering = false;
      deviceController.close();

      if (target == null) return;

      debugPrint('[Cast+Mine] User selected: ${target.name}');

      // ─── Phase 2: Push connecting page immediately, connect in background ───
      // No white screen — the user sees a black page with "Connecting..." spinner
      // while we load subtitles and establish the cast session.

      if (!context.mounted) return;

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => _CastSetupPage(
          deviceName: target.name,
          appModel: appModel,
          setupFuture: _connectAndLoad(
            target: target,
            item: item,
            jItemFuture: jItemFuture,
          ),
        ),
      ));
    } catch (e) {
      debugPrint('[Cast+Mine] ❌ Fatal error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cast failed: $e')));
      }
    }
    _isDiscovering = false;
  }

  /// Performs all async setup (item fetch, subtitles, device connection)
  /// and returns the ready-to-use [CastSession] and subtitles.
  ///
  /// This runs while [_CastSetupPage] shows a loading spinner, so the user
  /// never sees a white screen.
  Future<_CastSetupResult> _connectAndLoad({
    required CastTarget target,
    required MediaItem item,
    required Future<server_core.MediaItem> jItemFuture,
  }) async {
    debugPrint('[Cast+Mine] Connecting to ${target.name}...');

    final jItem = await jItemFuture;

    final extra = jsonDecode(item.extra ?? '{}') as Map<String, dynamic>;
    var msId = extra['mediaSourceId'] as String? ?? '';
    if (msId.isEmpty) {
      msId = jItem.mediaSources.isNotEmpty ? jItem.mediaSources.first.id : '';
    }
    if (msId.isEmpty) throw Exception('No media source.');

    // Load subtitles.
    final subs = <SubtitleItem>[];
    try {
      final service = SubtitleService(
        (iid, sid, idx) => _c.playbackApi.getSubtitleContent(iid, sid, idx),
      );
      subs.addAll(await service.loadSubtitles(
        itemId: item.mediaIdentifier,
        subtitleStreams: jItem.mediaStreams
            .where((s) => s.type == 'Subtitle')
            .map((s) => SubtitleStreamMeta(
                  index: s.index,
                  codec: s.codec,
                  displayTitle: s.displayTitle,
                  language: s.language,
                  isExternal: s.isExternal ?? false,
                  deliveryUrl: s.deliveryUrl,
                ))
            .toList(),
        mediaSourceId: msId,
      ));
    } catch (_) {}

    // Chromecast (Google Cast via mDNS / CastV2 protocol).
    if (target.isChromecast) {
      debugPrint('[Cast+Mine] → Chromecast path: ${target.name}');
      final chromecastDevice = target.chromecastDevice ??
          ChromecastDevice(
            name: target.ssdpDevice?.name ?? target.name,
            host: target.ssdpDevice?.ip ?? '',
            port: target.ssdpDevice?.port ?? 8009,
            id: target.ssdpDevice?.ip ?? '',
          );

      final streamUrl = _c.playbackApi.getStreamUrl(item.mediaIdentifier, msId);
      debugPrint('[Cast+Mine] Stream URL: $streamUrl');
      final ctrl = await ChromecastController.connect(
        device: chromecastDevice,
        streamUrl: streamUrl,
        contentType: 'video/mp4',
        title: item.title ?? target.name,
      );
      if (ctrl == null) {
        throw Exception('Chromecast connection failed.');
      }
      debugPrint('[Cast+Mine] ✅ Chromecast connected');
      return _CastSetupResult(castSession: ctrl, subtitles: subs);
    }

    // DLNA (UPnP / SOAP — CDATA fix applied).
    if (target.isDlna && target.ssdpDevice?.locationUrl != null) {
      debugPrint('[Cast+Mine] → DLNA path: ${target.name}');
      final streamUrl = _c.playbackApi.getStreamUrl(item.mediaIdentifier, msId);
      final ctrl = await DlnaController.connect(
        streamUrl: streamUrl,
        deviceLocationUrl: target.ssdpDevice!.locationUrl!,
        deviceName: target.ssdpDevice!.name,
        dlnaDevice: target.ssdpDevice!.dlnaDevice,
      );
      if (ctrl == null) {
        throw Exception('DLNA connection failed.');
      }
      debugPrint('[Cast+Mine] ✅ DLNA connected');
      return _CastSetupResult(castSession: ctrl, subtitles: subs);
    }

    // Jellyfin cast.
    if (!target.isJellyfin || target.jellyfinDevice == null) {
      throw Exception('Invalid cast target.');
    }
    debugPrint('[Cast+Mine] → Jellyfin cast path: ${target.jellyfinDevice!.name}');
    final dev = target.jellyfinDevice!;
    final controller = CastController(
      sessionApi: _c.sessionApi,
      deviceId: dev.id,
      deviceName: dev.name,
    );
    final ok = await controller.startPlayback(
      itemId: item.mediaIdentifier,
      mediaSourceId: msId,
    );
    if (!ok) {
      throw Exception('Could not start playback on ${dev.name}.');
    }
    debugPrint('[Cast+Mine] ✅ Jellyfin cast started');
    await Future.delayed(const Duration(seconds: 2));
    return _CastSetupResult(castSession: controller, subtitles: subs);
  }

  // ─── Image / Audio Generation (Mining) ──────────────────────────────────

  /// Override to use the Jellyfin stream URL instead of the item ID as
  /// FFmpeg's input. The base class uses [MediaItem.mediaIdentifier] which
  /// is the Jellyfin server-side item ID — FFmpeg can't read that.
  @override
  Future<List<NetworkToFileImage>> generateImages({
    required AppModel appModel,
    required MediaItem item,
    List<Subtitle>? subtitles,
    SubtitleOptions? options,
    String? data,
  }) async {
    final extra = jsonDecode(item.extra ?? '{}') as Map<String, dynamic>;
    final msId = extra['mediaSourceId'] as String? ?? '';
    if (msId.isNotEmpty && _client != null) {
      final streamUrl = _client!.playbackApi.getStreamUrl(
        item.mediaIdentifier, msId,
      );
      final modifiedItem = item.copyWith(mediaIdentifier: streamUrl);
      return super.generateImages(
        appModel: appModel, item: modifiedItem,
        subtitles: subtitles, options: options, data: data,
      );
    }
    return super.generateImages(
      appModel: appModel, item: item,
      subtitles: subtitles, options: options, data: data,
    );
  }

  @override
  Future<File?>? generateAudio({
    required AppModel appModel,
    required MediaItem item,
    List<Subtitle>? subtitles,
    SubtitleOptions? options,
    String? data,
  }) async {
    final extra = jsonDecode(item.extra ?? '{}') as Map<String, dynamic>;
    final msId = extra['mediaSourceId'] as String? ?? '';
    if (msId.isNotEmpty && _client != null) {
      final streamUrl = _client!.playbackApi.getStreamUrl(
        item.mediaIdentifier, msId,
      );
      final modifiedItem = item.copyWith(mediaIdentifier: streamUrl);
      return super.generateAudio(
        appModel: appModel, item: modifiedItem,
        subtitles: subtitles, options: options, data: data,
      );
    }
    return super.generateAudio(
      appModel: appModel, item: item,
      subtitles: subtitles, options: options, data: data,
    );
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────

  void cleanup() {
    _client?.dispose();
    _browseCache.clear();
    _itemCache.clear();
    _subtitleCache.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cast Setup — immediate page transition (no white screen)
// ─────────────────────────────────────────────────────────────────────────────

/// Holds the result of connecting to a cast device + loading subtitles.
class _CastSetupResult {
  final CastSession castSession;
  final List<SubtitleItem> subtitles;

  const _CastSetupResult({
    required this.castSession,
    required this.subtitles,
  });
}

/// A lightweight page shown immediately after the user picks a cast device.
///
/// Displays a "Connecting..." spinner while [setupFuture] runs in the
/// background. When the future completes, transitions seamlessly to
/// [MiningModePage]. If it fails, shows an error with a back button.
///
/// This replaces the old behavior where the user would see a white screen
/// (the player page behind the picker) for 2-5 seconds while subtitles
/// loaded and the cast session was established.
class _CastSetupPage extends StatefulWidget {
  final String deviceName;
  final AppModel appModel;
  final Future<_CastSetupResult> setupFuture;

  const _CastSetupPage({
    required this.deviceName,
    required this.appModel,
    required this.setupFuture,
  });

  @override
  State<_CastSetupPage> createState() => _CastSetupPageState();
}

class _CastSetupPageState extends State<_CastSetupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<_CastSetupResult>(
        future: widget.setupFuture,
        builder: (context, snapshot) {
          // Error state.
          if (snapshot.hasError) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Could not connect to\n${widget.deviceName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Loading state.
          if (!snapshot.hasData) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Connecting to',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.deviceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Loading subtitles…',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Ready — show MiningModePage.
          final result = snapshot.data!;
          return MiningModePage(
            castSession: result.castSession,
            subtitles: result.subtitles,
            onExitMining: () async {
              await result.castSession.stop();
              if (mounted) Navigator.pop(context);
            },
            appModel: widget.appModel,
          );
        },
      ),
    );
  }
}

/// Wraps [JellyfinLibraryPage] as a [BasePage] so it can be used as
/// the history page for the Jellyfin media source.
class _JellyfinLibraryWrapperPage extends BasePage {
  const _JellyfinLibraryWrapperPage({super.key});

  @override
  BasePageState<_JellyfinLibraryWrapperPage> createState() =>
      _JellyfinLibraryWrapperPageState();
}

class _JellyfinLibraryWrapperPageState
    extends BasePageState<_JellyfinLibraryWrapperPage> {
  @override
  Widget build(BuildContext context) => const JellyfinLibraryPage();
}
