import 'package:flutter/foundation.dart';
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/utils.dart';

/// Maps a Jellyfin subtitle codec string to a [SubtitleType].
///
/// Supported formats: SRT, ASS/SSA, VTT, TTML/DFXP.
/// Unsupported formats (bitmap): PGS, DVB, VobSub — returns null.
SubtitleType? subtitleTypeFromCodec(String? codec) {
  if (codec == null) return SubtitleType.srt;

  switch (codec.toLowerCase()) {
    case 'srt':
    case 'subrip':
      return SubtitleType.srt;
    case 'ass':
    case 'ssa':
      return SubtitleType.ssa;
    case 'vtt':
    case 'webvtt':
      return SubtitleType.vtt;
    case 'ttml':
      return SubtitleType.ttml;
    case 'dfxp':
      return SubtitleType.dfxp;
    case 'sbv':
      return SubtitleType.sbv;
    case 'pgssub':
    case 'dvbsub':
    case 'dvb_subtitle':
    case 'vobsub':
    case 'hdmv_pgs_subtitle':
      // Bitmap subtitles are not parseable as text.
      return null;
    default:
      // Unknown codec — try SRT as fallback.
      debugPrint('[SubtitleService] Unknown subtitle codec "$codec", falling back to SRT');
      return SubtitleType.srt;
  }
}

/// Metadata about a single subtitle stream, passed to [SubtitleService].
///
/// This avoids depending on any specific MediaItem or MediaStream class
/// — the caller extracts just the fields needed for subtitle resolution.
class SubtitleStreamMeta {
  final int index;
  final String? codec;
  final String? displayTitle;
  final String? language;
  final bool isExternal;
  final String? deliveryUrl;

  const SubtitleStreamMeta({
    required this.index,
    this.codec,
    this.displayTitle,
    this.language,
    this.isExternal = false,
    this.deliveryUrl,
  });
}

/// Resolves and parses subtitles for a Jellyfin media item.
///
/// **Model-agnostic** — does not depend on any `MediaItem` type.
/// Receives raw data (itemId, streams, sourceId) so it works with
/// both the old `JellyfinItem` and new `server_core.MediaItem`.
class SubtitleService {
  /// Callback that fetches raw subtitle content from the server.
  final Future<String> Function(String itemId, String mediaSourceId, int index) _fetchContent;

  final Map<String, String> _contentCache = {};
  final Map<String, SubtitleItem> _parsedCache = {};

  SubtitleService(this._fetchContent);

  /// Loads all available subtitles for a media item.
  ///
  /// [itemId] is the Jellyfin item ID.
  /// [subtitleStreams] is the list of subtitle streams (only Subtitle type).
  /// [mediaSourceId] is the media source to pull subtitles from.
  ///
  /// Skips unsupported formats (bitmaps) and tracks that fail to parse.
  Future<List<SubtitleItem>> loadSubtitles({
    required String itemId,
    required List<SubtitleStreamMeta> subtitleStreams,
    required String mediaSourceId,
  }) async {
    if (subtitleStreams.isEmpty) return [];

    final results = <SubtitleItem>[];

    for (final stream in subtitleStreams) {
      final type = subtitleTypeFromCodec(stream.codec);
      if (type == null) {
        debugPrint('[SubtitleService] Skipping bitmap subtitle: ${stream.displayTitle}');
        continue;
      }

      try {
        final subtitle = await _loadSingle(
          itemId: itemId,
          stream: stream,
          mediaSourceId: mediaSourceId,
          type: type,
        );
        if (subtitle != null) {
          results.add(subtitle);
        }
      } catch (e) {
        debugPrint('[SubtitleService] Failed to parse "${stream.displayTitle}": $e');
        continue;
      }
    }

    return results;
  }

  Future<SubtitleItem?> _loadSingle({
    required String itemId,
    required SubtitleStreamMeta stream,
    required String mediaSourceId,
    required SubtitleType type,
  }) async {
    final cacheKey = _cacheKey(itemId, mediaSourceId, stream.index);

    if (_parsedCache.containsKey(cacheKey)) {
      return _parsedCache[cacheKey];
    }

    String content;
    if (_contentCache.containsKey(cacheKey)) {
      content = _contentCache[cacheKey]!;
    } else {
      content = await _fetchContent(itemId, mediaSourceId, stream.index);
      _contentCache[cacheKey] = content;
    }

    final controller = SubtitleController(
      provider: SubtitleProvider.fromString(data: content, type: type),
    );

    final subtitle = SubtitleItem(
      controller: controller,
      type: SubtitleItemType.webSubtitle,
      metadata: stream.displayTitle ?? stream.language ?? 'Subtitle',
      index: stream.index,
    );

    _parsedCache[cacheKey] = subtitle;
    return subtitle;
  }

  void clearCache() {
    _contentCache.clear();
    _parsedCache.clear();
  }

  String _cacheKey(String itemId, String sourceId, int streamIndex) =>
      '$itemId-$sourceId-$streamIndex';
}
