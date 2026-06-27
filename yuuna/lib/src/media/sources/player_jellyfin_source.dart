import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:server_core/server_core.dart' as server_core;
import 'package:server_jellyfin/server_jellyfin.dart' as server_jellyfin;
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

  bool get isLoggedIn => _client?.accessToken != null && _client?.userId != null;
  server_jellyfin.JellyfinMediaServerClient? get serverClient => _client;

  void setServerClient(server_jellyfin.JellyfinMediaServerClient? client) {
    _client?.dispose();
    _client = client;
  }

  // ─── Connection Management ─────────────────────────────────────────────

  Future<bool> restoreSession() async {
    final url = getPreference<String?>(key: 'jellyfin_server_url', defaultValue: null);
    final token = getPreference<String?>(key: 'jellyfin_access_token', defaultValue: null);
    final uid = getPreference<String?>(key: 'jellyfin_user_id', defaultValue: null);
    if (url == null || token == null || uid == null) return false;

    _client = server_jellyfin.JellyfinMediaServerClient(
      baseUrl: url,
      deviceInfo: _deviceInfo,
      accessToken: token,
      userId: uid,
    );
    try {
      await _client!.itemsApi.getViews();
      return true;
    } catch (_) {
      _client = null;
      return false;
    }
  }

  Future<bool> connectToServer(String url, String username, String password) async {
    _client = server_jellyfin.JellyfinMediaServerClient(
      baseUrl: url,
      deviceInfo: _deviceInfo,
    );
    try {
      final r = await _client!.authApi.authenticateByName(username, password);
      _client!.setCredentials(accessToken: r.accessToken, userId: r.userId);
      await setPreference<String?>(key: 'jellyfin_server_url', value: url);
      await setPreference<String?>(key: 'jellyfin_access_token', value: r.accessToken);
      await setPreference<String?>(key: 'jellyfin_user_id', value: r.userId);
      return true;
    } catch (_) {
      _client = null;
      rethrow;
    }
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
    if (_browseCache.containsKey(cacheKey)) return _browseCache[cacheKey]!;

    List<server_core.MediaItem> items;
    final pt = parentType?.toLowerCase();
    if ((pt == 'series') && seriesId != null) {
      // Get seasons for a TV series.
      items = await _c.itemsApi.getSeasons(seriesId);
    } else if ((pt == 'season') && seriesId != null) {
      // Get episodes for a TV season.
      items = await _c.itemsApi.getEpisodes(seriesId, parentId);
    } else {
      // Generic: folders, views, mixed libraries.
      items = await _c.itemsApi.getItems(parentId, recursive: parentType == null);
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
            ? 'S${item.parentIndexNumber!.padLeft(2, '0')}E${item.indexNumber.toString().padLeft(2, '0')}'
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

    // Use media_kit for Jellyfin streaming.
    final service = MediaKitPlayerService(_c.playbackApi);
    // Cap start time to avoid seeking to the very end (e.g. if Jellyfin
    // reports the item as fully watched via PlaybackPositionTicks = RunTimeTicks).
    final duration = item.duration > 0 ? item.duration : 0;
    final startTime = item.position < duration - 10 ? item.position : 0;
    final (:player, :videoController) = await service.createPlayer(
      itemId: item.mediaIdentifier,
      mediaSourceId: msId,
      startTime: startTime,
    );
    return UniversalPlayerController.mediaKit(
      player: player,
      videoController: videoController,
    );
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
      if (jItem.mediaStreams.isEmpty) return [];
      if (msId.isEmpty) msId = jItem.mediaSources.isNotEmpty ? jItem.mediaSources.first.id : '';

      final service = SubtitleService(
        (iid, sid, idx) => _c.playbackApi.getSubtitleContent(iid, sid, idx),
      );
      return service.loadSubtitles(
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
      );
    } catch (_) {
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
    try {
      final jItem = await _c.itemsApi.getItem(item.mediaIdentifier);

      // Discover.
      final discovery = DeviceDiscovery(_c.sessionApi);
      final devices = await discovery.discover();
      if (devices.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cast devices found.')),
          );
        }
        return;
      }

      if (!context.mounted) return;
      final target = await DevicePicker.show(context: context, devices: devices);
      if (target == null) return;

      final extra = jsonDecode(item.extra ?? '{}') as Map<String, dynamic>;
      var msId = extra['mediaSourceId'] as String? ?? '';
      if (msId.isEmpty) msId = jItem.mediaSources.isNotEmpty ? jItem.mediaSources.first.id : '';
      if (msId.isEmpty) throw Exception('No media source.');

      // Subtitles.
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
                    index: s.index, codec: s.codec,
                    displayTitle: s.displayTitle, language: s.language,
                    isExternal: s.isExternal ?? false, deliveryUrl: s.deliveryUrl,
                  ))
              .toList(),
          mediaSourceId: msId,
        ));
      } catch (_) {}

      // Chromecast (Google Cast via mDNS / CastV2 protocol).
      // Must be checked BEFORE DLNA — Chromecasts may also respond to
      // DIAL SSDP, which would incorrectly route them to the DLNA path.
      if (target.isChromecast) {
        // Build a ChromecastDevice from whichever source is available.
        final chromecastDevice = target.chromecastDevice ??
            ChromecastDevice(
              name: target.ssdpDevice?.name ?? target.name,
              host: target.ssdpDevice?.ip ?? '',
              port: target.ssdpDevice?.port ?? 8009,
              id: target.ssdpDevice?.ip ?? '',
            );

        final streamUrl = _c.playbackApi.getStreamUrl(item.mediaIdentifier, msId);
        final ctrl = await ChromecastController.connect(
          device: chromecastDevice,
          streamUrl: streamUrl,
          contentType: 'video/mp4',
          title: item.title ?? target.name,
        );
        if (ctrl == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chromecast connection failed.')));
          }
          return;
        }
        if (!context.mounted) return;
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => MiningModePage(
            castSession: ctrl, subtitles: subs,
            onExitMining: () async { await ctrl.stop(); Navigator.pop(ctx); },
            appModel: appModel,
          ),
        ));
        return;
      }

      // DLNA.
      if (target.isDlna && target.ssdpDevice?.locationUrl != null) {
        final streamUrl = _c.playbackApi.getStreamUrl(item.mediaIdentifier, msId);
        final ctrl = await DlnaController.connect(
          streamUrl: streamUrl,
          deviceLocationUrl: target.ssdpDevice!.locationUrl!,
          deviceName: target.ssdpDevice!.name,
        );
        if (ctrl == null) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DLNA connection failed.')));
          return;
        }
        if (!context.mounted) return;
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => MiningModePage(
            castSession: ctrl, subtitles: subs,
            onExitMining: () async { await ctrl.stop(); Navigator.pop(ctx); },
            appModel: appModel,
          ),
        ));
        return;
      }

      // Jellyfin cast.
      if (!target.isJellyfin || target.jellyfinDevice == null) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid cast target.')));
        return;
      }
      final dev = target.jellyfinDevice!;
      final controller = CastController(
        sessionApi: _c.sessionApi,
        deviceId: dev.id,
        deviceName: dev.name,
      );
      final ok = await controller.startPlayback(itemId: item.mediaIdentifier, mediaSourceId: msId);
      if (!ok) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start playback on TV.')));
        return;
      }
      await Future.delayed(const Duration(seconds: 2));
      if (!context.mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => MiningModePage(
          castSession: controller, subtitles: subs,
          onExitMining: () async { await controller.stop(); Navigator.pop(ctx); },
          appModel: appModel,
        ),
      ));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cast failed: $e')));
      }
    }
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────

  void cleanup() {
    _client?.dispose();
    _browseCache.clear();
    _itemCache.clear();
    _subtitleCache.clear();
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
