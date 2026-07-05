import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_cast_dlna/media_cast_dlna.dart';

import 'cast_models.dart';

/// Controls a DLNA/UPnP cast session via [MediaCastDlnaApi] (jUPnP).
///
/// Sends a stream URL to a TV/renderer, then polls the playback position
/// for subtitle synchronization. Replaces the old raw UPnP SOAP implementation
/// with the event-driven jUPnP stack from `media_cast_dlna`.
///
/// Used by [MiningModePage] to keep subtitles in sync with the TV.
class DlnaController extends CastSession {
  final MediaCastDlnaApi _api;
  final DeviceUdn _udn;
  final String _deviceName;

  DlnaController({
    required MediaCastDlnaApi api,
    required DeviceUdn udn,
    required String deviceName,
  })  : _api = api,
        _udn = udn,
        _deviceName = deviceName;

  // ─── State ─────────────────────────────────────────────────────────────

  CastSessionState _state = CastSessionState.connecting;
  CastPosition _position = CastPosition.empty;
  Timer? _pollTimer;
  int _consecutiveFailures = 0;
  static const int _maxFailures = 5;
  static const Duration _pollInterval = Duration(milliseconds: 500);

  // ─── Getters ───────────────────────────────────────────────────────────

  /// The transport state for the current session.
  CastSessionState get state => _state;

  /// The latest position record from the remote renderer.
  CastPosition get position => _position;

  /// Human-readable device name.
  String get deviceName => _deviceName;

  /// The UDN of the controlled DLNA device.
  DeviceUdn get udn => _udn;

  bool get isActive =>
      _state == CastSessionState.playing || _state == CastSessionState.paused;

  /// The sync-adjusted position for subtitle matching.
  Duration get syncedPosition => _position.syncedPosition;

  // ─── Startup ───────────────────────────────────────────────────────────

  /// Sends a stream URL to the DLNA renderer and starts playback.
  ///
  /// Uses [MediaCastDlnaApi.setMediaUri] followed by [MediaCastDlnaApi.play].
  static Future<DlnaController?> connect({
    required MediaCastDlnaApi api,
    required String streamUrl,
    required String title,
    required DeviceUdn udn,
    String? deviceName,
    Duration? mediaDuration,
  }) async {
    try {
      final metadata = VideoMetadata(
        title: title,
        duration: mediaDuration != null
            ? TimeDuration(seconds: mediaDuration.inSeconds)
            : TimeDuration(seconds: 0),
        resolution: '',
        genre: '',
        upnpClass: 'object.item.videoItem.movie',
      );

      await api.setMediaUri(
        udn,
        Url(value: streamUrl),
        metadata,
      );

      await api.play(udn);

      final controller = DlnaController(
        api: api,
        udn: udn,
        deviceName: deviceName ?? 'DLNA Device',
      );
      controller._state = CastSessionState.playing;
      controller.startPolling();
      return controller;
    } catch (e) {
      debugPrint('[DlnaCtrl] Connect failed: $e');
      return null;
    }
  }

  // ─── Position Polling ─────────────────────────────────────────────────

  void startPolling() {
    stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    _poll(); // Immediate first poll.
  }

  Future<void> _poll() async {
    try {
      final position = await _api.getCurrentPosition(_udn);
      final state = await _api.getTransportState(_udn);

      _position = CastPosition(
        remotePosition: Duration(seconds: position.seconds),
        isPlaying: state == TransportState.playing,
        syncOffset: _position.syncOffset,
        estimatedLatency: _position.estimatedLatency,
      );

      switch (state) {
        case TransportState.playing:
          _state = CastSessionState.playing;
          break;
        case TransportState.paused:
          _state = CastSessionState.paused;
          break;
        case TransportState.stopped:
        case TransportState.noMediaPresent:
          _state = CastSessionState.ended;
          break;
        case TransportState.transitioning:
          // Keep current state during transitions.
          break;
      }

      _consecutiveFailures = 0;
      notifyListeners();
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

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ─── Playback Control ──────────────────────────────────────────────────

  Future<void> play() async {
    try {
      await _api.play(_udn);
      _state = CastSessionState.playing;
      notifyListeners();
    } catch (e) {
      debugPrint('[DlnaCtrl] Play failed: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _api.pause(_udn);
      _state = CastSessionState.paused;
      notifyListeners();
    } catch (e) {
      debugPrint('[DlnaCtrl] Pause failed: $e');
    }
  }

  Future<void> stop() async {
    stopPolling();
    try {
      await _api.stop(_udn);
    } catch (e) {
      debugPrint('[DlnaCtrl] Stop failed: $e');
    }
    _state = CastSessionState.ended;
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_state == CastSessionState.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekForward(Duration amount) async {
    await seek(_position.remotePosition + amount);
  }

  Future<void> seekBackward(Duration amount) async {
    final target = _position.remotePosition - amount;
    await seek(target < Duration.zero ? Duration.zero : target);
  }

  @override
  bool get isPlaying => _position.isPlaying;

  @override
  Duration get syncOffset => _position.syncOffset;

  Future<void> seek(Duration position) async {
    try {
      await _api.seek(_udn, TimePosition(seconds: position.inSeconds));
      _position = CastPosition(
        remotePosition: position,
        isPlaying: _position.isPlaying,
        syncOffset: _position.syncOffset,
        estimatedLatency: _position.estimatedLatency,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('[DlnaCtrl] Seek failed: $e');
    }
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

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
