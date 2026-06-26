import '../models/playback_models.dart';

/// User views API contract — library views/folders.
///
/// User views represent top-level library groupings (Movies, TV, Music, etc.).
abstract class UserViewsApi {
  /// Gets all user views (libraries) visible to the current user.
  Future<List<MediaItem>> getViews();

  /// Gets a specific view by ID.
  Future<MediaItem> getView(String viewId);
}
