/// Playback API contract — streaming URLs and progress reporting.
abstract class PlaybackApi {
  /// Returns the direct stream URL for a media item.
  ///
  /// [itemId] is the item to stream.
  /// [mediaSourceId] is the specific media source to use.
  /// [deviceId] is a unique identifier for this device.
  /// [audioCodec] optionally forces a specific audio codec.
  String getStreamUrl(
    String itemId,
    String mediaSourceId, {
    String? deviceId,
    String? audioCodec,
  });

  /// Gets the raw subtitle content for a given media item.
  ///
  /// [itemId] is the media item.
  /// [mediaSourceId] is the media source that has the subtitle.
  /// [subtitleIndex] is the index of the subtitle stream.
  /// [format] is the subtitle format to request (srt, ass, vtt).
  Future<String> getSubtitleContent(
    String itemId,
    String mediaSourceId,
    int subtitleIndex, {
    String? format,
  });

  /// Reports playback progress to the server.
  ///
  /// [itemId] is the item being played.
  /// [positionTicks] is the current position in ticks (1 tick = 100ns).
  /// [isPaused] whether playback is paused.
  Future<void> reportPlaybackProgress(
    String itemId,
    int positionTicks, {
    bool? isPaused,
  });

  /// Reports that playback has started.
  Future<void> reportPlaybackStart(String itemId, String mediaSourceId);

  /// Reports that playback has stopped.
  Future<void> reportPlaybackStop(
    String itemId, {
    int? positionTicks,
  });
}
