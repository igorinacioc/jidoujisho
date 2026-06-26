import '../models/playback_models.dart';

/// User library API contract — recently added, continue watching, favorites.
abstract class UserLibraryApi {
  /// Gets recently added items across all libraries.
  Future<List<MediaItem>> getLatestItems({
    int? startIndex,
    int? limit,
    List<String>? includeItemTypes,
  });

  /// Gets items the user has partially watched (Continue Watching).
  Future<List<MediaItem>> getResumeItems({
    int? startIndex,
    int? limit,
  });

  /// Marks an item as favorite/unfavorite.
  Future<void> setFavorite(String itemId, bool isFavorite);

  /// Marks an item as played/unplayed.
  Future<void> setPlayed(String itemId, bool isPlayed);

  /// Gets items the user has favorited.
  Future<List<MediaItem>> getFavorites({
    int? startIndex,
    int? limit,
  });
}
