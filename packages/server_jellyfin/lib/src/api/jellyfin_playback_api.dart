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
  }) {
    final params = <String, String>{
      'Static': 'true',
      'MediaSourceId': mediaSourceId,
      'ApiKey': _token,
    };
    if (deviceId != null) params['DeviceId'] = deviceId;
    if (audioCodec != null) params['AudioCodec'] = audioCodec;

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
    // Jellyfin 10.11+ uses file extension for format (Stream.vtt), not query param.
    // Older versions accept ?format=srt on /Stream (without extension).
    // We default to .vtt (WebVTT) which works on 10.11+.
    final ext = format != null && format.isNotEmpty ? format : 'vtt';
    final response = await _dio.get(
      '/Videos/$itemId/$mediaSourceId/Subtitles/$subtitleIndex/Stream.$ext',
      queryParameters: {'api_key': _token},
      options: Options(
        responseType: ResponseType.plain,
        headers: {'Accept': 'text/plain'},
      ),
    );
    return response.data as String;
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
