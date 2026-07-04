import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server_core/server_core.dart' as server_core;
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A dedicated Jellyfin library screen — Moonfin-style grid of cards.
///
/// Shows the user's library views as a browsable grid with poster art,
/// Continue Watching row, and Latest Media row.
class JellyfinLibraryPage extends ConsumerStatefulWidget {
  const JellyfinLibraryPage({super.key});

  @override
  ConsumerState<JellyfinLibraryPage> createState() => _JellyfinLibraryPageState();
}

class _JellyfinLibraryPageState extends ConsumerState<JellyfinLibraryPage> {
  List<server_core.MediaItem>? _views;
  List<server_core.MediaItem>? _continueWatching;
  List<server_core.MediaItem>? _latest;
  bool _loading = true;
  String? _error;

  PlayerJellyfinSource get _source => PlayerJellyfinSource.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    debugPrint('[JellyfinLibrary] Loading library...');

    try {
      if (!_source.isLoggedIn) {
        debugPrint('[JellyfinLibrary] Not logged in, restoring session...');
        await _source.restoreSession();
      }
      if (!_source.isLoggedIn) {
        debugPrint('[JellyfinLibrary] Session restore failed.');
        setState(() { _loading = false; _error = 'Not connected. Open settings to connect.'; });
        return;
      }

      debugPrint('[JellyfinLibrary] Fetching views + resume + latest...');
      final results = await Future.wait([
        _source.getViews(),
        _source.serverClient!.userLibraryApi.getResumeItems(limit: 10).catchError((e) {
          debugPrint('[JellyfinLibrary] Resume items error: $e');
          return <server_core.MediaItem>[];
        }),
        _source.serverClient!.userLibraryApi.getLatestItems(limit: 10).catchError((e) {
          debugPrint('[JellyfinLibrary] Latest items error: $e');
          return <server_core.MediaItem>[];
        }),
      ]);

      final views = results[0] as List<server_core.MediaItem>;
      final resumeItems = results[1] as List<server_core.MediaItem>;
      final latestItems = results[2] as List<server_core.MediaItem>;
      debugPrint('[JellyfinLibrary] Loaded: ${views.length} views, '
          '${resumeItems.length} resume, ${latestItems.length} latest');

      if (mounted) {
        setState(() {
          _views = views;
          _continueWatching = resumeItems;
          _latest = latestItems;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[JellyfinLibrary] ❌ Load error: $e');
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError();
    if (_views == null || _views!.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_continueWatching != null && _continueWatching!.isNotEmpty) ...[
            _sectionHeader('Continue Watching'),
            _horizontalCardRow(_continueWatching!),
            const SizedBox(height: 16),
          ],
          if (_latest != null && _latest!.isNotEmpty) ...[
            _sectionHeader('Latest Media'),
            _horizontalCardRow(_latest!),
            const SizedBox(height: 16),
          ],
          _sectionHeader('Libraries'),
          _viewsGrid(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
  );

  Widget _viewsGrid() => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: _views!.length,
    itemBuilder: (context, index) => _libraryCard(_views![index]),
  );

  Widget _horizontalCardRow(List<server_core.MediaItem> items) => SizedBox(
    height: 200,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) => _posterCard(items[index]),
    ),
  );

  Widget _posterCard(server_core.MediaItem item) => GestureDetector(
    onTap: () => _playItem(item),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 120,
            height: 160,
            child: _itemImage(item, width: 120),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 120,
          child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );

  Widget _libraryCard(server_core.MediaItem view) => GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => JellyfinBrowsePage(parentItem: view),
      ));
    },
    child: Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _itemImage(view, width: 200),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(view.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  if (view.childCount != null)
                    Text('${view.childCount} items', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _itemImage(server_core.MediaItem item, {double width = 200}) {
    final client = _source.serverClient;
    final imageTag = item.imageTags.isNotEmpty ? (item.imageTags['Primary'] ?? item.imageTags.values.first) : null;
    if (client != null && imageTag != null) {
      return CachedNetworkImage(
        imageUrl: client.imageApi.getImageUrl(item.id, imageTag, imageType: 'Primary'),
        fit: BoxFit.cover,
        width: width,
        placeholder: (_, __) => Container(color: Colors.grey[900]),
        errorWidget: (_, __, ___) => _placeholderIcon(item),
      );
    }
    return _placeholderIcon(item);
  }

  Widget _placeholderIcon(server_core.MediaItem item) => Container(
    color: Colors.grey[850],
    child: Center(child: Icon(item.isFolder == true ? Icons.folder : Icons.movie, size: 40, color: Colors.grey[600])),
  );

  void _playItem(server_core.MediaItem item) {
    final appModel = ref.read(appProvider);
    final mediaItem = _source.createMediaItem(item);
    appModel.openMedia(mediaSource: _source, ref: ref, item: mediaItem);
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 12),
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('Jellyfin Settings'),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const JellyfinSettingsDialogPage(),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.live_tv, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        const Text('Connect to Jellyfin to browse your library.'),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('Jellyfin Settings'),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const JellyfinSettingsDialogPage(),
          ).then((_) => _load()),
        ),
      ],
    ),
  );
}
