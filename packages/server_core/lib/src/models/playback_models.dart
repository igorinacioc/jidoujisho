import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_models.freezed.dart';
part 'playback_models.g.dart';

/// A media item from the server (movie, episode, series, etc.).
@freezed
class MediaItem with _$MediaItem {
  const factory MediaItem({
    required String id,
    required String name,

    /// The item type (Movie, Episode, Series, Folder, etc.).
    String? type,

    /// Long-form description / synopsis.
    String? overview,

    /// Original title (e.g. Japanese title for anime).
    String? originalTitle,

    /// Available media sources (streamable versions).
    @Default([]) List<MediaSource> mediaSources,

    /// Available media streams (video, audio, subtitle tracks).
    @Default([]) List<MediaStream> mediaStreams,

    /// Duration in ticks (1 tick = 100ns).
    int? runTimeTicks,

    /// Year of production.
    int? productionYear,

    /// Episode number (for episodes).
    int? indexNumber,

    /// Season number (for episodes).
    String? parentIndexNumber,

    /// The parent series ID (for seasons and episodes).
    String? seriesId,

    /// Name of the parent series.
    String? seriesName,

    /// Name of the season.
    String? seasonName,

    /// Image tags keyed by image type (Primary, Backdrop, Logo, etc.).
    @Default({}) Map<String, String> imageTags,

    /// User-specific data (playback position, favorite status, etc.).
    @Default({}) Map<String, dynamic> userData,

    /// Whether this item is a folder/collection (can be browsed into).
    bool? isFolder,

    /// Number of child items (for folders).
    int? childCount,

    /// Backdrop image tags.
    @Default([]) List<String> backdropImageTags,
  }) = _MediaItem;

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);
}

/// A media source (a specific version/encoding of a media item).
@freezed
class MediaSource with _$MediaSource {
  const factory MediaSource({
    required String id,

    /// File path on the server.
    String? path,

    /// Container format (mp4, mkv, etc.).
    String? container,

    /// Bitrate in bits per second.
    int? bitrate,

    /// Whether this source supports direct stream (no transcoding).
    bool? supportsDirectStream,

    /// Whether this source supports transcoding.
    bool? supportsTranscoding,

    /// Source type (Default, etc.).
    String? type,

    /// Human-readable name for this source.
    String? name,

    /// Size of the media file in bytes.
    int? size,
  }) = _MediaSource;

  factory MediaSource.fromJson(Map<String, dynamic> json) =>
      _$MediaSourceFromJson(json);
}

/// A media stream (a specific track within a media source).
@freezed
class MediaStream with _$MediaStream {
  const factory MediaStream({
    /// The stream index within the container.
    required int index,

    /// Codec name (h264, aac, srt, etc.).
    String? codec,

    /// Human-readable title for this stream.
    String? displayTitle,

    /// Language code (eng, jpn, etc.).
    String? language,

    /// Stream type (Video, Audio, Subtitle).
    String? type,

    /// Whether this is the default track of its type.
    bool? isDefault,

    /// Whether this is an external file.
    bool? isExternal,

    /// For external subtitles, the delivery URL.
    String? deliveryUrl,
  }) = _MediaStream;

  factory MediaStream.fromJson(Map<String, dynamic> json) =>
      _$MediaStreamFromJson(json);
}

/// Extra data attached to a MediaItem for player initialization.
@freezed
class MediaItemExtra with _$MediaItemExtra {
  const factory MediaItemExtra({
    /// The media source ID to use for streaming.
    required String mediaSourceId,

    /// The server base URL (for constructing stream/image URLs).
    required String serverUrl,

    /// Overview/synopsis of the item.
    String? overview,

    /// Parent series name.
    String? seriesName,

    /// Season name.
    String? seasonName,

    /// Episode label (e.g. "S01E05").
    String? episodeLabel,

    /// Item type string from the server.
    String? itemType,

    /// Production year as a string.
    String? productionYear,
  }) = _MediaItemExtra;

  factory MediaItemExtra.fromJson(Map<String, dynamic> json) =>
      _$MediaItemExtraFromJson(json);
}
