import '../models/playback_models.dart';

/// Items API contract — browsing and searching the media library.
abstract class ItemsApi {
  /// Gets the user's library views (e.g., "Movies", "TV Shows").
  Future<List<MediaItem>> getViews();

  /// Gets items from a specific parent folder or library.
  ///
  /// [parentId] is the folder/library ID to browse.
  /// [sortBy] determines the sort field (default: 'SortName').
  /// [sortOrder] determines the sort direction.
  /// [recursive] fetches items from sub-folders.
  /// [includeItemTypes] filters by item types (e.g. ['Movie', 'Episode']).
  /// [startIndex] for pagination.
  /// [limit] maximum number of items to return.
  Future<List<MediaItem>> getItems(
    String parentId, {
    String sortBy,
    String sortOrder,
    bool recursive,
    List<String>? includeItemTypes,
    int? startIndex,
    int? limit,
  });

  /// Gets detailed info about a specific item.
  ///
  /// Includes MediaSources and MediaStreams for playback.
  Future<MediaItem> getItem(String itemId);

  /// Searches for items across all libraries.
  Future<List<MediaItem>> searchItems(
    String query, {
    List<String>? includeItemTypes,
    int? startIndex,
    int? limit,
  });

  /// Gets the next up episodes for a series.
  Future<List<MediaItem>> getNextUp({
    int? startIndex,
    int? limit,
  });

  /// Gets the user's continue-watching / resume items.
  Future<List<MediaItem>> getResumeItems({
    int? startIndex,
    int? limit,
  });

  /// Gets seasons for a series.
  Future<List<MediaItem>> getSeasons(String seriesId);

  /// Gets episodes for a season.
  Future<List<MediaItem>> getEpisodes(
    String seriesId,
    String seasonId, {
    int? startIndex,
    int? limit,
  });
}
