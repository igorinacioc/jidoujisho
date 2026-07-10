import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:server_core/server_core.dart';

/// Jellyfin implementation of [PlaybackApi].
class JellyfinPlaybackApi implements PlaybackApi {
  final Dio _dio;
  final String _baseUrl;
  String Function() _getAccessToken;

  JellyfinPlaybackApi(this._dio, this._baseUrl, this._getAccessToken);

  String get _token => _getAccessToken();

  @override
  String getStreamUrl(
    String itemId,
    String mediaSourceId, {
    String? deviceId,
    String? audioCodec,
    bool transcode = false,
  }) {
    final params = <String, String>{
      'MediaSourceId': mediaSourceId,
      'ApiKey': _token,
    };

    if (transcode) {
      // Universal DLNA-compatible transcoding: H.264 video + AAC audio in MPEG-TS.
      // Samsung, LG, and most Smart TVs support this combination.
      params['VideoCodec'] = 'h264';
      params['AudioCodec'] = audioCodec ?? 'aac';
      params['TranscodingContainer'] = 'ts';
    } else {
      // Direct play — preserves original quality, all audio/subtitle tracks.
      params['Static'] = 'true';
    }

    if (deviceId != null) params['DeviceId'] = deviceId;
    if (!transcode && audioCodec != null) params['AudioCodec'] = audioCodec;

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$_baseUrl/Videos/$itemId/stream?$query';
  }

  @override
  Future<String> getSubtitleContent(
    String itemId,
    String mediaSourceId,
    int subtitleIndex, {
    String? format,
  }) async {
    final ext = format != null && format.isNotEmpty ? format : 'vtt';
    final path = '/Videos/$itemId/$mediaSourceId/Subtitles/$subtitleIndex/Stream.$ext';
    developer.log('[JellyfinPlaybackApi] Fetching subtitle: $path');
    try {
      final response = await _dio.get(
        path,
        queryParameters: {'api_key': _token},
        options: Options(
          responseType: ResponseType.plain,
          headers: {'Accept': 'text/plain'},
        ),
      );
      final content = response.data as String;
      developer.log('[JellyfinPlaybackApi] ✅ Subtitle fetched: ${content.length} chars, '
          'status=${response.statusCode}');
      return content;
    } catch (e) {
      developer.log('[JellyfinPlaybackApi] ❌ Subtitle fetch failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> reportPlaybackProgress(
    String itemId,
    int positionTicks, {
    bool? isPaused,
  }) async {
    await _dio.post('/Sessions/Playing/Progress', data: {
      'ItemId': itemId,
      'PositionTicks': positionTicks,
      if (isPaused != null) 'IsPaused': isPaused,
    });
  }

  @override
  Future<void> reportPlaybackStart(String itemId, String mediaSourceId) async {
    await _dio.post('/Sessions/Playing', data: {
      'ItemId': itemId,
      'MediaSourceId': mediaSourceId,
      'CanSeek': true,
      'PlayMethod': 'DirectStream',
    });
  }

  @override
  Future<void> reportPlaybackStop(
    String itemId, {
    int? positionTicks,
  }) async {
    await _dio.post('/Sessions/Playing/Stopped', data: {
      'ItemId': itemId,
      if (positionTicks != null) 'PositionTicks': positionTicks,
    });
  }
}
