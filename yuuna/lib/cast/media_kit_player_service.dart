import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:server_core/server_core.dart';

/// Creates and configures a [Player] (media_kit/libmpv) for Jellyfin streaming.
///
/// Wraps the media_kit library to provide a pluggable alternative to VLC.
/// Uses [PlaybackApi] for stream URL resolution and subtitle retrieval.
class MediaKitPlayerService {
  final PlaybackApi _playbackApi;

  MediaKitPlayerService(this._playbackApi);

  /// Creates a media_kit [Player] configured for streaming from Jellyfin.
  ///
  /// [itemId] is the Jellyfin item ID.
  /// [mediaSourceId] is the specific media source to use.
  /// [startTime] is the position to start from (in seconds).
  /// Returns a tuple of [Player] and [VideoController] ready for the UI.
  Future<({Player player, VideoController videoController})> createPlayer({
    required String itemId,
    required String mediaSourceId,
    int startTime = 0,
  }) async {
    // Build the stream URL using PlaybackApi.
    final streamUrl = _playbackApi.getStreamUrl(itemId, mediaSourceId);

    // Create and configure the player.
    final player = Player(
      configuration: const PlayerConfiguration(
        title: 'Jellyfin Stream',
      ),
    );

    // Create a video controller for rendering.
    final videoController = VideoController(player);

    // Open the stream with start position.
    await player.open(
      Media(streamUrl),
      play: true,
    );
    // Seek to start position if needed (only if not at the very end).
    if (startTime > 0) {
      // Avoid seeking to near-end in case Jellyfin reports fully watched items.
      final dur = player.state.duration.inSeconds;
      if (dur == 0 || startTime < dur - 10) {
        await player.seek(Duration(seconds: startTime));
      }
    }

    return (player: player, videoController: videoController);
  }

  /// Creates a media_kit [Player] for audio-only playback.
  Future<({Player player, VideoController videoController})> createAudioPlayer({
    required String itemId,
    required String mediaSourceId,
  }) async {
    final streamUrl = _playbackApi.getStreamUrl(
      itemId,
      mediaSourceId,
      audioCodec: 'aac',
    );

    final player = Player();
    final videoController = VideoController(player);

    await player.open(Media(streamUrl));

    return (player: player, videoController: videoController);
  }
}
