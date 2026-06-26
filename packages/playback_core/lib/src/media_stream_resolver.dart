import 'stream_resolution_result.dart';

/// Abstract interface for resolving a media item into a playable stream URL.
///
/// Implementations handle server-specific logic:
/// - [JellyfinMediaStreamResolver] calls the Jellyfin PlaybackInfo API,
///   selects the best media source, and builds the stream URL.
abstract class MediaStreamResolver {
  /// Resolves a media item into a playable [StreamResolutionResult].
  ///
  /// [mediaItem] is the item to resolve (server-specific type).
  /// [deviceProfile] describes the client's playback capabilities.
  /// [startTimeTicks] is the position to start from.
  /// [mediaSourceId] optionally selects a specific media source.
  Future<StreamResolutionResult> resolve(
    dynamic mediaItem, {
    int? startTimeTicks,
    String? mediaSourceId,
    String? audioStreamIndex,
    String? subtitleStreamIndex,
    bool enableDirectPlay = true,
    bool enableDirectStream = true,
  });
}
