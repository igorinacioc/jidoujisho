import 'dart:async';
import 'package:flutter/foundation.dart';
import 'cast_cors_proxy.dart';
import 'cast_models.dart';
import 'castv2_protocol.dart';
import 'chromecast_discovery.dart';

/// Controls a Chromecast session — implements [CastSession].
///
/// Connects to a Chromecast device via the CastV2 protocol, launches the
/// Default Media Receiver, and manages playback with position polling
/// for subtitle synchronization in [MiningModePage].
class ChromecastController extends CastSession {
  final ChromecastDevice _device;
  final String _streamUrl;
  CastV2Connection? _connection;
  CastCorsProxy? _proxy;
  CastSessionState _state = CastSessionState.connecting;
  CastPosition _position = CastPosition.empty;
  Timer? _pollTimer;
  int _consecutiveFailures = 0;
  static const int _maxFailures = 5;
  bool _disposed = false;

  ChromecastController._({
    required ChromecastDevice device,
    required String streamUrl,
  })  : _device = device,
        _streamUrl = streamUrl;

  // ─── Getters ───────────────────────────────────────────────────────────
  CastSessionState get state => _state;
  CastPosition get position => _position;
  String get deviceName => _device.name;
  bool get isActive => _state == CastSessionState.playing || _state == CastSessionState.paused;
  Duration get syncedPosition => _position.syncedPosition;
  @override bool get isPlaying => _position.isPlaying;
  @override Duration get syncOffset => _position.syncOffset;

  /// Connects to the Chromecast and starts playback.
  static Future<ChromecastController?> connect({
    required ChromecastDevice device,
    required String streamUrl,
    String? contentType,
    String? title,
    String? imageUrl,
  }) async {
    try {
      final proxy = await CastCorsProxy.start(streamUrl);
      if (proxy == null) return null;
      final mediaUrl = proxy.publicUrl;

      final connection = CastV2Connection(host: device.host, port: device.port);
      if (!await connection.connect()) { proxy?.stop(); return null; }
      if (!await connection.launchReceiver()) { connection.disconnect(); proxy?.stop(); return null; }
      if (!await connection.loadMedia(url: mediaUrl, contentType: contentType ?? 'video/mp4', title: title, imageUrl: imageUrl)) {
        connection.disconnect(); proxy?.stop(); return null;
      }

      final controller = ChromecastController._(device: device, streamUrl: streamUrl);
      controller._connection = connection;
      controller._proxy = proxy;
      controller._state = CastSessionState.playing;
      controller._position = CastPosition(remotePosition: Duration.zero, isPlaying: true);

      connection.onChange.stream.listen((_) {
        if (!controller._disposed) controller._updateFromConnection();
      });

      controller.startPolling();
      controller.notifyListeners();
      return controller;
    } catch (_) { return null; }
  }

  void _updateFromConnection() {
    final conn = _connection; if (conn == null) return;
    _position = CastPosition(remotePosition: conn.currentPosition, isPlaying: conn.isPlaying, syncOffset: _position.syncOffset, estimatedLatency: _position.estimatedLatency);
    _state = conn.isPlaying ? CastSessionState.playing : CastSessionState.paused;
    if (!conn.isConnected) { _state = CastSessionState.ended; stopPolling(); }
    _consecutiveFailures = 0;
    notifyListeners();
  }

  void startPolling() { stopPolling(); _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _poll()); }
  Future<void> _poll() async { try { _connection?.getStatus(); _consecutiveFailures = 0; } catch (_) { _consecutiveFailures++; if (_consecutiveFailures >= _maxFailures) { stopPolling(); _state = CastSessionState.reconnecting; notifyListeners(); } } }
  void stopPolling() { _pollTimer?.cancel(); _pollTimer = null; }

  @override Future<void> playPause() async { if (_state == CastSessionState.playing) { await _connection?.pause(); } else { await _connection?.play(); } }
  @override Future<void> seek(Duration position) async { await _connection?.seek(position); }
  @override Future<void> seekForward(Duration amount) async { await seek(_position.remotePosition + amount); }
  @override Future<void> seekBackward(Duration amount) async { final target = _position.remotePosition - amount; await seek(target < Duration.zero ? Duration.zero : target); }
  @override Future<void> stop() async { stopPolling(); _connection?.stop(); _state = CastSessionState.ended; notifyListeners(); }
  @override void adjustSyncOffset(Duration delta) { _position = CastPosition(remotePosition: _position.remotePosition, isPlaying: _position.isPlaying, syncOffset: _position.syncOffset + delta, estimatedLatency: _position.estimatedLatency); notifyListeners(); }
  @override void resetSyncOffset() { _position = CastPosition(remotePosition: _position.remotePosition, isPlaying: _position.isPlaying, syncOffset: Duration.zero, estimatedLatency: _position.estimatedLatency); notifyListeners(); }
  @override void dispose() { _disposed = true; stopPolling(); _connection?.disconnect(); _proxy?.stop(); super.dispose(); }
}
