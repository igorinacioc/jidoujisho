/// Result of resolving a media item into a playable stream.
class StreamResolutionResult {
  /// The resolved stream URL.
  final String url;

  /// The playback method used (DirectPlay, DirectStream, Transcode).
  final String playMethod;

  /// External subtitles available with this stream.
  final List<ExternalSubtitle> externalSubtitles;

  /// The media type (video or audio).
  final String mediaType;

  /// Optional HLS audio remux URL for hybrid playback.
  final String? hybridAudioUrl;

  /// Normalization gain in dB, if reported by the server.
  final double? normalizationGainDb;

  const StreamResolutionResult({
    required this.url,
    required this.playMethod,
    this.externalSubtitles = const [],
    this.mediaType = 'video',
    this.hybridAudioUrl,
    this.normalizationGainDb,
  });
}

/// An external subtitle track referenced by the stream.
class ExternalSubtitle {
  final String deliveryUrl;
  final String? title;
  final String? language;
  final String codec;
  final bool isDefault;
  final bool isForced;
  final int? streamIndex;

  const ExternalSubtitle({
    required this.deliveryUrl,
    this.title,
    this.language,
    this.codec = 'srt',
    this.isDefault = false,
    this.isForced = false,
    this.streamIndex,
  });
}
