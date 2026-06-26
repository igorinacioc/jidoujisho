import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:server_core/server_core.dart';
import 'package:yuuna/cast/cast_models.dart';

/// Controls a Jellyfin remote playback session for "Cast + Mine".
///
/// Uses `SessionApi` (abstract) to send commands and poll position —
/// never tied to a concrete implementation. This enables:
/// - Unit testing with mocked `SessionApi`
/// - Swapping Jellyfin for Emby without changing this class
///
/// The `syncedPosition` getter provides the subtitle-sync-adjusted position
/// that the mining mode page uses to determine which subtitle to show.
class CastController extends CastSession {
  final SessionApi _sessionApi;

  String? _sessionId;
  final String _deviceId;
  final String _deviceName;

  CastSessionState _state = CastSessionState.disconnected;
  CastPosition _position = CastPosition.empty;
  Timer? _pollTimer;
  int _consecutiveFailures = 0;
  static const int _maxFailures = 5;
  Duration _pollInterval = const Duration(milliseconds: 500);

  // ─── Constructor ───────────────────────────────────────────────────────

  CastController({
    required SessionApi sessionApi,
    required String deviceId,
    required String deviceName,
  })  : _sessionApi = sessionApi,
        _deviceId = deviceId,
        _deviceName = deviceName;

  // ─── Getters ───────────────────────────────────────────────────────────

  CastSessionState get state => _state;
  CastPosition get position => _position;
  String? get sessionId => _sessionId;
  String get deviceId => _deviceId;
  String get deviceName => _deviceName;

  @override
  bool get isActive => _state == CastSessionState.playing || _state == CastSessionState.paused;

  @override
  bool get isPlaying => _position.isPlaying;

  @override
  Duration get syncOffset => _position.syncOffset;

  @override
  Duration get syncedPosition => _position.syncedPosition;

  // ─── Startup ───────────────────────────────────────────────────────────

  /// Starts playback on the target device and begins position polling.
  ///
  /// Call this after the user picks a cast target.
  /// Returns `true` if the session was successfully created.
  Future<bool> startPlayback({
    required String itemId,
    required String mediaSourceId,
  }) async {
    _state = CastSessionState.connecting;
    notifyListeners();

    try {
      // Start playback via the Jellyfin server.
      final sessionId = await _sessionApi.startPlayback(
        itemId,
        mediaSourceId,
        _deviceId,
      );

      if (sessionId == null || sessionId.isEmpty) {
        _state = CastSessionState.disconnected;
        notifyListeners();
        return false;
      }

      _sessionId = sessionId;
      _state = CastSessionState.playing;
      notifyListeners();

      // Begin polling for position.
      startPolling();
      return true;
    } catch (_) {
      _state = CastSessionState.disconnected;
      notifyListeners();
      return false;
    }
  }

  /// Attaches to an existing session (e.g. on reconnect).
  Future<bool> attachToSession() async {
    _state = CastSessionState.connecting;
    notifyListeners();

    try {
      final session = await _sessionApi.getSession(_deviceId);
      if (session != null) {
        _sessionId = session.id;
        _position = CastPosition(
          remotePosition: Duration(microseconds: session.positionTicks ~/ 10),
          isPlaying: !session.isPaused,
        );
        _state = session.isPaused ? CastSessionState.paused : CastSessionState.playing;
        _consecutiveFailures = 0;
        notifyListeners();
        startPolling();
        return true;
      }
      _state = CastSessionState.disconnected;
      notifyListeners();
      return false;
    } catch (_) {
      _state = CastSessionState.disconnected;
      notifyListeners();
      return false;
    }
  }

  // ─── Position Polling ─────────────────────────────────────────────────

  void startPolling() {
    stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    _poll(); // Immediate first poll.
  }

  Future<void> _poll() async {
    if (_sessionId == null) {
      _handleFailure();
      return;
    }

    final startTime = DateTime.now();

    try {
      final session = await _sessionApi.getSession(_deviceId);
      if (session != null) {
        _sessionId = session.id;
        final responseTime = DateTime.now().difference(startTime).inMilliseconds;
        _position = CastPosition(
          remotePosition: Duration(microseconds: session.positionTicks ~/ 10),
          isPlaying: !session.isPaused,
          syncOffset: _position.syncOffset,
          estimatedLatency: Duration(
            milliseconds: ((_position.estimatedLatency.inMilliseconds * 3) + responseTime) ~/ 4,
          ),
        );
        _state = session.isPaused ? CastSessionState.paused : CastSessionState.playing;
        _consecutiveFailures = 0;
        notifyListeners();
      } else {
        // Session ended on the server.
        _handleSessionEnded();
      }
    } catch (_) {
      _handleFailure();
    }
  }

  void _handleFailure() {
    _consecutiveFailures++;
    if (_consecutiveFailures >= _maxFailures) {
      stopPolling();
      _state = CastSessionState.ended;
      notifyListeners();
    }
  }

  void _handleSessionEnded() {
    stopPolling();
    _sessionId = null;
    _state = CastSessionState.ended;
    notifyListeners();
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ─── Playback Commands ─────────────────────────────────────────────────

  Future<void> playPause() async {
    if (_sessionId == null) return;
    try {
      if (_state == CastSessionState.playing) {
        await _sessionApi.pause(_sessionId!);
        _state = CastSessionState.paused;
      } else {
        await _sessionApi.play(_sessionId!);
        _state = CastSessionState.playing;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> seek(Duration position) async {
    if (_sessionId == null) return;
    try {
      await _sessionApi.seek(_sessionId!, position);
      _position = CastPosition(
        remotePosition: position,
        isPlaying: _position.isPlaying,
        syncOffset: _position.syncOffset,
        estimatedLatency: _position.estimatedLatency,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> seekForward(Duration amount) async {
    await seek(_position.remotePosition + amount);
  }

  Future<void> seekBackward(Duration amount) async {
    final target = _position.remotePosition - amount;
    await seek(target < Duration.zero ? Duration.zero : target);
  }

  Future<void> stop() async {
    stopPolling();
    if (_sessionId != null) {
      try {
        await _sessionApi.stop(_sessionId!);
      } catch (_) {}
    }
    _sessionId = null;
    _state = CastSessionState.ended;
    notifyListeners();
  }

  // ─── Sync Offset ──────────────────────────────────────────────────────

  void adjustSyncOffset(Duration delta) {
    _position = CastPosition(
      remotePosition: _position.remotePosition,
      isPlaying: _position.isPlaying,
      syncOffset: _position.syncOffset + delta,
      estimatedLatency: _position.estimatedLatency,
    );
    notifyListeners();
  }

  void resetSyncOffset() {
    _position = CastPosition(
      remotePosition: _position.remotePosition,
      isPlaying: _position.isPlaying,
      syncOffset: Duration.zero,
      estimatedLatency: _position.estimatedLatency,
    );
    notifyListeners();
  }

  // ─── Poll Interval ─────────────────────────────────────────────────────

  void setPollInterval(Duration interval) {
    final clamped = interval.inMilliseconds.clamp(200, 2000);
    _pollInterval = Duration(milliseconds: clamped);
    if (_pollTimer != null) startPolling();
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
