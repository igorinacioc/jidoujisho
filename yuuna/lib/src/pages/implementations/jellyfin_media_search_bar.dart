import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:server_core/server_core.dart' as server_core;
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The search bar used for the Jellyfin media source.
///
/// When the search bar is focused with an empty query, it shows
/// the Jellyfin library views for browsing. When a query is entered,
/// it searches within the Jellyfin library.
class JellyfinMediaSearchBar extends BaseMediaSearchBar {
  /// Create an instance of this bar.
  const JellyfinMediaSearchBar({super.key});

  @override
  BaseMediaSearchBarState<JellyfinMediaSearchBar> createState() =>
      _JellyfinMediaSearchBarState();
}

/// State for [JellyfinMediaSearchBar].
class _JellyfinMediaSearchBarState
    extends BaseMediaSearchBarState<JellyfinMediaSearchBar> {
  @override
  MediaSource get mediaSource => PlayerJellyfinSource.instance;

  @override
  MediaType get mediaType => PlayerMediaType.instance;

  @override
  Duration get searchDelay => const Duration(milliseconds: 500);

  PlayerJellyfinSource get _source => PlayerJellyfinSource.instance;

  @override
  void initState() {
    super.initState();
    // Restore session so JellyfinLibraryPage works immediately.
    if (!_source.isLoggedIn) {
      _source.restoreSession();
    }
  }

  @override
  Widget buildFloatingSearchBody(
    BuildContext context,
    Animation<double> transition,
  ) {
    // If the user is not logged in, show a prompt.
    if (!_source.isLoggedIn) {
      return Center(
        child: JidoujishoPlaceholderMessage(
          icon: Icons.live_tv,
          message: 'Open Jellyfin Settings to connect to your server.',
        ),
      );
    }

    final query = mediaType.floatingSearchBarController.query.trim();

    // If user typed a query, use the standard search flow.
    if (query.isNotEmpty) {
      return super.buildFloatingSearchBody(context, transition);
    }

    // Show Moonfin-style library page when no query.
    return const JellyfinLibraryPage();
  }

  /// Shows when there are proper search results returned.
  @override
  Widget buildResultList() {
    return JellyfinSearchResultsPage(
      title: mediaType.floatingSearchBarController.query,
      pagingController: pagingController!,
      showAppBar: false,
    );
  }
}

/// A page for browsing Jellyfin library contents (folders and items).
class JellyfinBrowsePage extends ConsumerStatefulWidget {
  /// Create an instance of this page.
  const JellyfinBrowsePage({
    required this.parentItem,
    this.seriesId,
    super.key,
  });

  /// The parent folder/view to browse.
  final server_core.MediaItem parentItem;

  /// The series ID (passed through from parent when browsing seasons).
  final String? seriesId;

  @override
  ConsumerState<JellyfinBrowsePage> createState() => _JellyfinBrowsePageState();
}

class _JellyfinBrowsePageState extends ConsumerState<JellyfinBrowsePage> {
  List<server_core.MediaItem>? _items;
  bool _loading = true;

  PlayerJellyfinSource get _source => PlayerJellyfinSource.instance;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    final p = widget.parentItem;
    debugPrint('[JellyfinBrowse] Loading items: name="${p.name}" type="${p.type}" '
        'id="${p.id}" seriesId="${widget.seriesId}"');
    try {
      final seriesId = widget.seriesId ?? (p.type == 'Series' ? p.id : null);
      _items = await _source.getItems(
        p.id,
        parentType: p.type,
        seriesId: seriesId,
      );
      debugPrint('[JellyfinBrowse] ✅ Got ${_items?.length ?? 0} items');
      if (_items != null && _items!.isNotEmpty) {
        debugPrint('[JellyfinBrowse] First item: name="${_items![0].name}" '
            'type="${_items![0].type}" isFolder=${_items![0].isFolder}');
      }
    } catch (e) {
      debugPrint('[JellyfinBrowse] ❌ Error: $e');
      _items = null;
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentItem.name),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items == null || _items!.isEmpty) {
      return const Center(
        child: Text('No items found in this library.'),
      );
    }

    return ListView.builder(
      itemCount: _items!.length,
      itemBuilder: (context, index) {
        final item = _items![index];
        final isFolder = item.isFolder == true ||
            item.type == 'Series' || item.type == 'Season' ||
            item.type == 'Folder' || item.type == 'CollectionFolder';
        final imageTag = item.imageTags.isNotEmpty
            ? (item.imageTags['Primary'] ?? item.imageTags.values.first)
            : null;
        final client = _source.serverClient;

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 60,
              height: 90,
              child: client != null && imageTag != null
                  ? CachedNetworkImage(
                      imageUrl: client.imageApi.getImageUrl(item.id, imageTag, imageType: 'Primary'),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _namePlaceholder(item.name),
                      errorWidget: (_, __, ___) => _namePlaceholder(item.name),
                    )
                  : _namePlaceholder(item.name),
            ),
          ),
          title: Text(item.name),
          subtitle: item.productionYear != null
              ? Text('${item.productionYear}')
              : null,
          trailing: isFolder ? const Icon(Icons.chevron_right) : null,
          onTap: () {
            if (isFolder) {
              // Pass seriesId through: if this is a Series, its ID is the seriesId.
              final childSeriesId = item.type == 'Series' ? item.id : widget.seriesId;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => JellyfinBrowsePage(
                    parentItem: item,
                    seriesId: childSeriesId,
                  ),
                ),
              );
            } else {
              // Play the media item.
              final mediaItem = _source.createMediaItem(item);
              final appModel = ref.read(appProvider);
              appModel.openMedia(
                mediaSource: _source,
                ref: ref,
                item: mediaItem,
              );
            }
          },
        );
      },
    );
  }

  Widget _namePlaceholder(String name) => Container(
    color: Colors.blue[700],
    alignment: Alignment.center,
    padding: const EdgeInsets.all(4),
    child: Text(
      name,
      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    ),
  );
}

/// A page that displays Jellyfin search results.
class JellyfinSearchResultsPage extends HistoryPlayerPage {
  /// Create an instance of this page.
  const JellyfinSearchResultsPage({
    required this.title,
    required this.pagingController,
    required this.showAppBar,
    super.key,
  });

  /// Title to show under the page.
  final String title;

  /// Used for infinite scroll pagination.
  final PagingController<int, MediaItem> pagingController;

  /// Whether or not to show an app bar.
  final bool showAppBar;

  @override
  HistoryPlayerPageState<JellyfinSearchResultsPage> createState() =>
      _JellyfinSearchResultsPageState();
}

class _JellyfinSearchResultsPageState
    extends HistoryPlayerPageState<JellyfinSearchResultsPage> {
  @override
  bool get isHistory => false;

  @override
  MediaSource get mediaSource => PlayerJellyfinSource.instance;

  @override
  MediaType get mediaType => PlayerMediaType.instance;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: widget.showAppBar ? buildAppBar() : null,
      body: SafeArea(
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return RawScrollbar(
      thumbVisibility: true,
      thickness: 3,
      controller: _scrollController,
      child: buildList(),
    );
  }

  Widget buildList() {
    return PagedListView<int, MediaItem>(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      scrollController: _scrollController,
      pagingController: widget.pagingController,
      key: UniqueKey(),
      builderDelegate: PagedChildBuilderDelegate<MediaItem>(
        noItemsFoundIndicatorBuilder: (context) {
          return Center(
            child: JidoujishoPlaceholderMessage(
              icon: Icons.search_off,
              message: t.no_search_results,
            ),
          );
        },
        firstPageProgressIndicatorBuilder: (context) {
          return buildLoading();
        },
        newPageProgressIndicatorBuilder: (context) {
          return buildLoading();
        },
        itemBuilder: (context, item, index) {
          return buildMediaItem(item);
        },
      ),
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: JidoujishoMarquee(
            text: widget.title,
            style: TextStyle(
              fontSize: textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildBackButton(),
      title: buildTitle(),
      titleSpacing: 8,
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: t.back,
      icon: Icons.arrow_back,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildMetadata(MediaItem item) {
    MediaSource source = item.getMediaSource(appModel: appModel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source.getDisplayTitleFromMediaItem(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 8),
        Text(
          source.getDisplaySubtitleFromMediaItem(item),
          style: TextStyle(
            color: Theme.of(context).unselectedWidgetColor,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              source.icon,
              color: Theme.of(context).unselectedWidgetColor,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              source.getLocalisedSourceName(appModel),
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ],
        ),
        ...extraMetadata(item),
      ],
    );
  }
}
