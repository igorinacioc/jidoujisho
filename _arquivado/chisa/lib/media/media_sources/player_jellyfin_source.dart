import 'dart:async';

import 'package:chisa/jellyfin/cast_session_manager.dart';
import 'package:chisa/jellyfin/device_picker_dialog.dart';
import 'package:chisa/jellyfin/jellyfin_client.dart';
import 'package:chisa/jellyfin/jellyfin_models.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/mining/mining_mode_page.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:chisa/util/subtitle_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subtitle/subtitle.dart';

/// Media source that integrates Jellyfin media server.
///
/// Allows browsing the Jellyfin library, streaming video,
/// and loading subtitles — all through the existing player architecture.
class PlayerJellyfinSource extends PlayerMediaSource {
  PlayerJellyfinSource()
      : super(
          sourceName: 'Jellyfin',
          icon: Icons.live_tv,
        );

  JellyfinClient? _client;

  /// Cached items for browsing (view / folder -> items).
  final Map<String, List<JellyfinItem>> _browseCache = {};

  /// Cached item details.
  final Map<String, JellyfinItem> _itemCache = {};

  /// Cached subtitle content.
  final Map<String, String> _subtitleCache = {};

  /// Whether the user is logged in to a Jellyfin server.
  bool get isLoggedIn => _client?.isAuthenticated ?? false;

  // ─── Connection Management ─────────────────────────────────────────────

  /// Tries to restore a saved Jellyfin session from SharedPreferences.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final serverUrl = prefs.getString('jellyfin_server_url');
    final accessToken = prefs.getString('jellyfin_access_token');
    final userId = prefs.getString('jellyfin_user_id');

    if (serverUrl == null || accessToken == null || userId == null) {
      return false;
    }

    _client = JellyfinClient(serverUrl);
    _client!.setCredentials(accessToken: accessToken, userId: userId);

    // Verify the session is still valid by making a test request.
    try {
      await _client!.getViews();
      return true;
    } catch (_) {
      _client = null;
      return false;
    }
  }

  /// Connects to a Jellyfin server and authenticates.
  Future<bool> connectToServer(
    String serverUrl,
    String username,
    String password,
  ) async {
    _client = JellyfinClient(serverUrl);

    try {
      final result = await _client!.authenticate(username, password);

      // Save credentials for next launch.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jellyfin_server_url', serverUrl);
      await prefs.setString('jellyfin_access_token', result.accessToken);
      await prefs.setString('jellyfin_user_id', result.userId);

      return true;
    } on JellyfinException {
      _client = null;
      rethrow;
    }
  }

  /// Disconnects from the Jellyfin server and clears saved credentials.
  Future<void> disconnect() async {
    _client?.logout();
    _client = null;
    _browseCache.clear();
    _itemCache.clear();
    _subtitleCache.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jellyfin_server_url');
    await prefs.remove('jellyfin_access_token');
    await prefs.remove('jellyfin_user_id');
  }

  /// Returns the current client, throwing if not connected.
  JellyfinClient get client {
    if (_client == null || !_client!.isAuthenticated) {
      throw JellyfinException('Not connected to Jellyfin server.');
    }
    return _client!;
  }

  // ─── Library Browsing ──────────────────────────────────────────────────

  /// Gets the list of library views (e.g., "Movies", "TV Shows").
  Future<List<JellyfinItem>> getViews() async {
    final views = await client.getViews();
    return views;
  }

  /// Gets items from a specific library folder with caching.
  Future<List<JellyfinItem>> getItems(String parentId) async {
    if (_browseCache.containsKey(parentId)) {
      return _browseCache[parentId]!;
    }

    final items = await client.getItems(parentId);
    _browseCache[parentId] = items;

    // Also cache individual items for quick lookup.
    for (final item in items) {
      _itemCache[item.id] = item;
    }

    return items;
  }

  /// Gets detailed info for an item, with caching.
  Future<JellyfinItem> getItemDetails(String itemId) async {
    if (_itemCache.containsKey(itemId)) {
      return _itemCache[itemId]!;
    }

    final item = await client.getItem(itemId);
    _itemCache[itemId] = item;
    return item;
  }

  // ─── Launch Params ─────────────────────────────────────────────────────

  @override
  PlayerLaunchParams getLaunchParams(
    AppModel appModel,
    MediaHistoryItem item,
  ) {
    return PlayerLaunchParams.network(
      appModel: appModel,
      networkPath: item.key,
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: true,
    );
  }

  // ─── Stream URL ────────────────────────────────────────────────────────

  @override
  FutureOr<String> getNetworkStreamUrl(PlayerLaunchParams params) async {
    final itemId = params.mediaHistoryItem.key;
    final mediaSourceId =
        params.mediaHistoryItem.extra['mediaSourceId'] as String? ?? '';

    if (mediaSourceId.isEmpty) {
      // If no media source was saved, fetch item details to get it.
      final item = await client.getItem(itemId);
      if (item.mediaSources != null && item.mediaSources!.isNotEmpty) {
        return client.getStreamUrl(itemId, item.mediaSources!.first.id);
      }
      throw JellyfinException('No media source available for streaming.');
    }

    return client.getStreamUrl(itemId, mediaSourceId);
  }

  // ─── Subtitles ─────────────────────────────────────────────────────────

  @override
  FutureOr<List<SubtitleItem>> provideSubtitles(
    PlayerLaunchParams params,
  ) async {
    final itemId = params.mediaHistoryItem.key;
    final mediaSourceId =
        params.mediaHistoryItem.extra['mediaSourceId'] as String? ?? '';

    try {
      // Find subtitle streams.
      final item = await getItemDetails(itemId);
      final subtitleStreams =
          item.mediaStreams?.where((s) => s.isSubtitle).toList() ?? [];

      if (subtitleStreams.isEmpty) return [];

      final List<SubtitleItem> results = [];

      for (final stream in subtitleStreams) {
        final cacheKey = '$itemId-$mediaSourceId-${stream.index}';

        // Download subtitle content with caching.
        String? content = _subtitleCache[cacheKey];
        if (content == null) {
          content = await client.getSubtitleContent(
            itemId,
            mediaSourceId.isNotEmpty
                ? mediaSourceId
                : (item.mediaSources?.first.id ?? ''),
            stream.index,
          );
          _subtitleCache[cacheKey] = content;
        }

        try {
          final controller = SubtitleController(
            provider: SubtitleProvider.fromString(
              data: content,
              type: SubtitleType.srt,
            ),
          );

          results.add(SubtitleItem(
            controller: controller,
            type: SubtitleItemType.webSubtitle,
            metadata: stream.displayTitle ?? stream.language ?? 'Subtitle',
            index: stream.index,
          ));
        } catch (_) {
          // Skip subtitle tracks that fail to parse.
          continue;
        }
      }

      return results;
    } catch (_) {
      return [];
    }
  }

  // ─── Media History Item Factory ────────────────────────────────────────

  /// Creates a [MediaHistoryItem] from a [JellyfinItem] for playback.
  MediaHistoryItem createHistoryItem(JellyfinItem item) {
    final mediaSourceId =
        item.mediaSources?.isNotEmpty == true ? item.mediaSources!.first.id : '';

    return MediaHistoryItem(
      key: item.id,
      title: item.name,
      author: item.seriesName ?? '',
      sourceName: sourceName,
      mediaTypePrefs: mediaType.prefsDirectory(),
      currentProgress: item.userData?['PlaybackPositionTicks'] != null
          ? (item.userData!['PlaybackPositionTicks'] as int) ~/ 10000000
          : 0,
      completeProgress: item.runTimeTicks != null
          ? item.runTimeTicks! ~/ 10000000
          : 0,
      extra: {
        'mediaSourceId': mediaSourceId,
        'serverUrl': _client?.serverUrl ?? '',
        'overview': item.overview ?? '',
        'seriesName': item.seriesName ?? '',
        'seasonName': item.seasonName ?? '',
        'episodeLabel': item.episodeLabel ?? '',
        'itemType': item.type ?? '',
        'productionYear': item.productionYear?.toString() ?? '',
      },
    );
  }

  // ─── History Item Metadata ─────────────────────────────────────────────

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    final seriesName = item.extra['seriesName'] as String? ?? '';
    final episodeLabel = item.extra['episodeLabel'] as String? ?? '';

    if (seriesName.isNotEmpty && episodeLabel.isNotEmpty) {
      return '$seriesName - $episodeLabel';
    }
    if (episodeLabel.isNotEmpty) {
      return episodeLabel;
    }
    return item.title;
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    final overview = item.extra['overview'] as String? ?? '';
    if (overview.isNotEmpty) {
      // Truncate to a reasonable length.
      return overview.length > 120
          ? '${overview.substring(0, 120)}...'
          : overview;
    }
    return item.author.isNotEmpty ? item.author : 'Jellyfin';
  }

  @override
  ImageProvider<Object> getHistoryThumbnail(MediaHistoryItem item) {
    final serverUrl = item.extra['serverUrl'] as String? ?? '';
    final itemId = item.key;

    // Use Jellyfin's primary image endpoint.
    // We don't have the image tag readily available, so use a fallback.
    if (serverUrl.isNotEmpty) {
      return NetworkImage(
        '$serverUrl/Items/$itemId/Images/Primary?quality=90',
      );
    }

    return const AssetImage('assets/images/video_placeholder.png');
  }

  // ─── Search ────────────────────────────────────────────────────────────

  @override
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) async {
    if (!isLoggedIn) return null;

    try {
      // Search all user libraries.
      final views = await getViews();
      final List<JellyfinItem> allItems = [];

      for (final view in views) {
        if (view.isFolder == true) {
          final items = await client.getItems(
            view.id,
            recursive: true,
            includeItemTypes: ['Movie', 'Episode'],
            startIndex: pageKey * getSearchPageSize,
            limit: getSearchPageSize,
          );
          allItems.addAll(items);
        }
      }

      // Filter by search term (client-side since Jellyfin search is complex).
      final query = searchTerm.toLowerCase();
      final filtered = allItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            (item.seriesName?.toLowerCase().contains(query) ?? false) ||
            (item.originalTitle?.toLowerCase().contains(query) ?? false) ||
            (item.overview?.toLowerCase().contains(query) ?? false);
      }).toList();

      return filtered.map((item) => createHistoryItem(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Extra History Actions ─────────────────────────────────────────────

  @override
  List<Widget> getExtraHistoryActions({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    if (!isLoggedIn) return [];

    return [
      TextButton(
        child: const Text('CAST + MINE'),
        onPressed: () async {
          Navigator.pop(context); // close the long-press dialog
          await _launchMiningMode(context, item);
          homeRefreshCallback();
          searchRefreshCallback();
        },
      ),
    ];
  }

  // ─── Mining Mode Launch ─────────────────────────────────────────────────

  /// Orchestrates the full cast + mining flow:
  /// 1. Discovers cast devices from Jellyfin
  /// 2. Shows device picker dialog
  /// 3. Starts playback on selected TV
  /// 4. Downloads subtitles
  /// 5. Launches MiningModePage
  Future<void> _launchMiningMode(
    BuildContext context,
    MediaHistoryItem item,
  ) async {
    try {
      // Step 1: Get item details.
      final jellyItem = await getItemDetails(item.key);

      // Step 2: Discover devices.
      final devices = await client.discoverCastDevices();

      if (devices.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No cast devices found. Make sure your TV is on.'),
            ),
          );
        }
        return;
      }

      // Step 3: Pick a device.
      final device = await DevicePickerDialog.show(
        context: context,
        devices: devices,
        serverName: client.serverUrl,
      );

      if (device == null) return; // User cancelled.

      // Step 4: Get media source ID.
      final mediaSourceId = item.extra['mediaSourceId'] as String? ??
          (jellyItem.mediaSources?.isNotEmpty == true
              ? jellyItem.mediaSources!.first.id
              : '');

      if (mediaSourceId.isEmpty) {
        throw JellyfinException('No media source available.');
      }

      // Step 5: Start playback on TV.
      await client.startPlayback(item.key, mediaSourceId, device.id);

      // Give the TV a moment to start.
      await Future.delayed(const Duration(seconds: 2));

      // Step 6: Set up cast session manager.
      final castSession = CastSessionManager();
      await castSession.attachToSession(
        client: client,
        deviceId: device.id,
      );

      // Step 7: Load subtitles.
      final subtitles = <SubtitleItem>[];
      try {
        final loaded = await provideSubtitles(
          getLaunchParams(
            Provider.of<AppModel>(context, listen: false),
            item,
          ),
        );
        subtitles.addAll(loaded);
      } catch (_) {
        // Continue without subtitles if they fail to load.
      }

      if (!context.mounted) return;

      // Step 8: Launch Mining Mode Page.
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => MiningModePage(
            castSession: castSession,
            subtitles: subtitles,
            onExitMining: () async {
              await castSession.stop();
              Navigator.pop(ctx);
            },
          ),
        ),
      );
    } on JellyfinException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start cast: $e')),
        );
      }
    }
  }

  // ─── Source Button ─────────────────────────────────────────────────────

  @override
  Widget? buildSourceButton(BuildContext context, PlayerPageState page) {
    if (!isLoggedIn) return null;

    return IconButton(
      icon: const Icon(Icons.cast),
      tooltip: 'Cast + Mine',
      onPressed: () async {
        final item = page.widget.params.mediaHistoryItem;
        await _launchMiningMode(context, item);
      },
    );
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────

  /// Cleans up resources. Call this when the source is no longer needed.
  void cleanup() {
    _client?.dispose();
    _browseCache.clear();
    _itemCache.clear();
    _subtitleCache.clear();
  }
}
