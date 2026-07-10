import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:server_core/server_core.dart';

/// Jellyfin implementation of [SessionApi].
///
/// Handles device listing, session management, and remote playback
/// control — the core of the "Cast + Mine" functionality.
class JellyfinSessionApi implements SessionApi {
  final Dio _dio;

  JellyfinSessionApi(this._dio);

  @override
  Future<List<SessionInfo>> getSessions() async {
    final response = await _dio.get('/Sessions');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => SessionInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SessionInfo?> getSession(String deviceId) async {
    final response = await _dio.get(
      '/Sessions',
      queryParameters: {'DeviceId': deviceId},
    );
    final List<dynamic> data = response.data as List<dynamic>;
    if (data.isEmpty) return null;
    return SessionInfo.fromJson(data.first as Map<String, dynamic>);
  }

  @override
  Future<List<ServerDevice>> getDevices() async {
    final response = await _dio.get('/Devices');
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => ServerDevice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String?> startPlayback(
    String itemId,
    String mediaSourceId,
    String deviceId,
  ) async {
    debugPrint('[JellyfinAPI] startPlayback: itemId=$itemId deviceId=$deviceId msId=$mediaSourceId');

    try {
      final existingSession = await getSession(deviceId);
      debugPrint('[JellyfinAPI] Existing session: ${existingSession != null ? existingSession.id : "NONE"}');
    } catch (e) {
      debugPrint('[JellyfinAPI] getSession check failed: $e');
    }

    try {
      final response = await _dio.post('/Sessions/Playing', data: {
        'ItemIds': [itemId],
        'PlayCommand': 'PlayNow',
        'MediaSourceId': mediaSourceId,
        'DeviceId': deviceId,
      });
      debugPrint('[JellyfinAPI] POST /Sessions/Playing → status=${response.statusCode}');
    } catch (e) {
      debugPrint('[JellyfinAPI] POST /Sessions/Playing ERROR: $e');
      return null;
    }

    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final session = await getSession(deviceId);
        debugPrint('[JellyfinAPI] Poll $i/5: session=${session != null ? session.id : "NULL"}');
        if (session != null) return session.id;
      } catch (e) {
        debugPrint('[JellyfinAPI] Poll $i/5 ERROR: $e');
      }
    }
    debugPrint('[JellyfinAPI] startPlayback FAILED: device=$deviceId');
    return null;
  }

  @override
  Future<void> sendCommand(
    String sessionId,
    String command, {
    int? seekTicks,
  }) async {
    final query = <String, dynamic>{};
    if (seekTicks != null) {
      query['SeekPositionTicks'] = seekTicks.toString();
    }

    await _dio.post(
      '/Sessions/$sessionId/Playing/$command',
      queryParameters: query.isNotEmpty ? query : null,
    );
  }

  @override
  Future<void> play(String sessionId) => sendCommand(sessionId, 'Play');

  @override
  Future<void> pause(String sessionId) => sendCommand(sessionId, 'Pause');

  @override
  Future<void> stop(String sessionId) => sendCommand(sessionId, 'Stop');

  @override
  Future<void> seek(String sessionId, Duration position) =>
      sendCommand(sessionId, 'Seek', seekTicks: position.inMicroseconds * 10);
}
