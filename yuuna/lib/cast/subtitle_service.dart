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
    if (subtitleStreams.isEmpty) {
      debugPrint('[SubtitleService] No subtitle streams provided.');
      return [];
    }

    debugPrint('[SubtitleService] Loading ${subtitleStreams.length} subtitles '
        'for item=$itemId source=$mediaSourceId');

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
          debugPrint('[SubtitleService] ✅ Loaded: ${stream.displayTitle ?? stream.codec} '
              '(${subtitle.controller.subtitles.length} cues)');
        }
      } catch (e) {
        debugPrint('[SubtitleService] ❌ Failed to parse "${stream.displayTitle}": $e');
        continue;
      }
    }

    debugPrint('[SubtitleService] Done: ${results.length}/${subtitleStreams.length} subtitles loaded.');
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
      debugPrint('[SubtitleService] Cache hit: $cacheKey');
      return _parsedCache[cacheKey];
    }

    String content;
    if (_contentCache.containsKey(cacheKey)) {
      content = _contentCache[cacheKey]!;
      debugPrint('[SubtitleService] Content cache hit: $cacheKey (${content.length} chars)');
    } else {
      content = await _fetchContent(itemId, mediaSourceId, stream.index);
      _contentCache[cacheKey] = content;
      final previewLen = content.length < 500 ? content.length : 500;
      debugPrint('[SubtitleService] Fetched subtitle idx=${stream.index}: '
          '${content.length} chars');
      debugPrint('[SubtitleService] Content preview:\n${content.substring(0, previewLen)}');
    }

    // Jellyfin always returns WebVTT regardless of original codec
    // (we request Stream.vtt). Auto-detect to avoid parsing VTT as SRT/ASS.
    final actualType = content.trimLeft().startsWith('WEBVTT')
        ? SubtitleType.vtt
        : content.trimLeft().startsWith('[Script Info]')
            ? SubtitleType.ssa
            : type;

    if (actualType != type) {
      debugPrint('[SubtitleService] Auto-detected format: $type → $actualType '
          '(content starts with "${content.trimLeft().substring(0, content.trimLeft().length < 30 ? content.trimLeft().length : 30)}")');
    }

    final controller = SubtitleController(
      provider: SubtitleProvider.fromString(data: content, type: actualType),
    );

    // The subtitle package's initial() uses compute(parseSubtitles, params) for
    // non-SRT types, but RegExp is not transferable across isolates in some
    // Flutter versions. This causes silent failure → 0 cues.
    // Workaround: parse WebVTT content directly with a regex created in-process.
    if (!controller.initialized) {
      await controller.initial();
    }

    // If the package parser failed, use our own VTT parser.
    if (controller.subtitles.isEmpty && actualType == SubtitleType.vtt) {
      debugPrint('[SubtitleService] Package parser returned 0 cues. Using built-in VTT parser...');
      final parsed = _parseVttDirect(content);
      if (parsed.isNotEmpty) {
        controller.subtitles.addAll(parsed);
        controller.initialized = true;
      }
    }

    debugPrint('[SubtitleService] Parsed subtitle idx=${stream.index}: '
        'initialized=${controller.initialized}, '
        'subtitles count=${controller.subtitles.length}');

    if (controller.subtitles.isEmpty) {
      debugPrint('[SubtitleService] ⚠️ WARNING: No cues parsed from subtitle index=${stream.index} '
          '(type=$type, codec=${stream.codec})');
    }

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

  /// Parses WebVTT content directly (bypasses the subtitle package's broken
  /// `compute()` call that can't pass `RegExp` between isolates).
  static List<Subtitle> _parseVttDirect(String content) {
    // WebVTT timestamp format: HH:MM:SS.mmm --> HH:MM:SS.mmm
    // With optional cue numbers, CSS positioning, and HTML tags.
    final regex = RegExp(
      r'(?:(\d+)\n)?' // optional cue number
      r'(\d{2}):(\d{2}):(\d{2})[.,](\d{3})\s*-->\s*' // start time
      r'(\d{2}):(\d{2}):(\d{2})[.,](\d{3})' // end time (without options part)
      r'(?:[^\n]*)?\n' // optional CSS positioning after -->, then newline
      r'((?:(?!\n\n).)*)', // text until blank line (non-greedy across lines)
      multiLine: true,
    );

    final matches = regex.allMatches(content);
    final subtitles = <Subtitle>[];

    for (final m in matches) {
      try {
        final start = Duration(
          hours: int.parse(m.group(2)!),
          minutes: int.parse(m.group(3)!),
          seconds: int.parse(m.group(4)!),
          milliseconds: int.parse(m.group(5)!),
        );
        final end = Duration(
          hours: int.parse(m.group(6)!),
          minutes: int.parse(m.group(7)!),
          seconds: int.parse(m.group(8)!),
          milliseconds: int.parse(m.group(9)!),
        );
        // Group 10 is the multi-line text.
        final text = (m.group(10) ?? '').trim();

        if (text.isNotEmpty) {
          subtitles.add(Subtitle(
            start: start,
            end: end,
            data: text,
            index: subtitles.length + 1,
          ));
        }
      } catch (_) {
        // Skip malformed cues.
      }
    }

    debugPrint('[SubtitleService] Built-in VTT parser: ${subtitles.length} cues extracted');
    return subtitles;
  }
}
