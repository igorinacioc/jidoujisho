import 'dart:async';

import 'package:flutter/foundation.dart';

import 'jellyfin_client.dart';

/// Manages an active Jellyfin cast session for the mining mode.
///
/// Polls the remote playback position, maintains sync state,
/// and provides remote control commands (play/pause/seek/stop).
///
/// Used by the [MiningModePage] to keep subtitles in sync with the TV.
class CastSessionManager extends ChangeNotifier {
  /// The Jellyfin client used for API calls.
  JellyfinClient? client;

  /// The current session ID, if a cast session is active.
  String? sessionId;

  /// The ID of the device being cast to (Chromecast/TV).
  String? deviceId;

  /// The last reported position from the remote session.
  Duration _remotePosition = Duration.zero;

  /// Whether the remote session is currently playing.
  bool _isPlaying = false;

  /// User-adjustable sync offset to compensate for network latency.
  Duration _syncOffset = Duration.zero;

  /// Estimated network latency based on response times.
  Duration _estimatedLatency = const Duration(milliseconds: 150);

  /// Timer that drives the position polling loop.
  Timer? _pollTimer;

  /// Polling interval for position checks.
  Duration _pollInterval = const Duration(milliseconds: 500);

  /// Number of consecutive poll failures before stopping.
  int _consecutiveFailures = 0;

  /// Maximum allowed consecutive failures before stopping.
  static const int _maxFailures = 5;

  // ─── Getters ───────────────────────────────────────────────────────────

  /// The current remote playback position.
  Duration get remotePosition => _remotePosition;

  /// Whether the cast session is active and playing.
  bool get isPlaying => _isPlaying;

  /// Whether we have an active cast session.
  bool get isActive => sessionId != null && client != null;

  /// The sync offset (user-adjustable).
  Duration get syncOffset => _syncOffset;

  /// The estimated network latency.
  Duration get estimatedLatency => _estimatedLatency;

  /// The synchronization-adjusted position for subtitle matching.
  ///
  /// Compensates for network latency and applies the user's sync offset.
  /// This is the position you should use to determine which subtitle to show.
  Duration get syncedPosition {
    final adjusted = _remotePosition + _syncOffset - _estimatedLatency;
    return adjusted < Duration.zero ? Duration.zero : adjusted;
  }

  // ─── Session Setup ─────────────────────────────────────────────────────

  /// Attaches to an existing cast session.
  ///
  /// Call this after [JellyfinClient.startPlayback] succeeds,
  /// or when reconnecting to an already-playing session.
  Future<void> attachToSession({
    required JellyfinClient client,
    required String deviceId,
  }) async {
    this.client = client;
    this.deviceId = deviceId;

    await _refreshSession();
  }

  /// Refreshes the session reference from the server.
  Future<void> _refreshSession() async {
    if (client == null || deviceId == null) return;

    try {
      final session = await client!.getSession(deviceId!);
      if (session != null) {
        sessionId = session.id;
        _remotePosition = Duration(microseconds: session.positionTicks ~/ 10);
        _isPlaying = !session.isPaused;
        _consecutiveFailures = 0;
        notifyListeners();
      }
    } catch (_) {
      // Will retry on next poll.
    }
  }

  // ─── Polling ───────────────────────────────────────────────────────────

  /// Starts the position polling loop.
  ///
  /// Call this when the mining mode UI becomes active.
  /// Stops any existing poll first.
  void startPolling() {
    stopPolling();

    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      await _poll();
    });

    // Also do an immediate poll.
    _poll();
  }

  /// Performs a single poll iteration.
  Future<void> _poll() async {
    if (client == null || deviceId == null) {
      _handlePollFailure();
      return;
    }

    final startTime = DateTime.now();

    try {
      final session = await client!.getSession(deviceId!);

      if (session != null) {
        sessionId = session.id;
        _remotePosition = Duration(microseconds: session.positionTicks ~/ 10);
        _isPlaying = !session.isPaused;
        _consecutiveFailures = 0;

        // Update latency estimate based on response time.
        final responseTime =
            DateTime.now().difference(startTime).inMilliseconds;
        _estimatedLatency = Duration(
          milliseconds: ((_estimatedLatency.inMilliseconds * 3) + responseTime) ~/ 4,
        );

        notifyListeners();
      } else {
        // Session ended on the server.
        _handleSessionEnded();
      }
    } catch (_) {
      _handlePollFailure();
    }
  }

  /// Handles a single poll failure.
  void _handlePollFailure() {
    _consecutiveFailures++;
    if (_consecutiveFailures >= _maxFailures) {
      stopPolling();
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Handles the session ending on the remote side.
  void _handleSessionEnded() {
    stopPolling();
    sessionId = null;
    _isPlaying = false;
    notifyListeners();
  }

  /// Stops the position polling loop.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ─── Playback Control ──────────────────────────────────────────────────

  /// Toggles play/pause on the remote session.
  Future<void> playPause() async {
    if (sessionId == null || client == null) return;
    try {
      await client!.playPause(sessionId!);
      _isPlaying = !_isPlaying;
      notifyListeners();
    } catch (_) {
      // Failed silently — next poll will correct state.
    }
  }

  /// Seeks to a position on the remote session.
  Future<void> seek(Duration position) async {
    if (sessionId == null || client == null) return;
    try {
      await client!.seek(sessionId!, position);
      _remotePosition = position;
      notifyListeners();
    } catch (_) {
      // Failed silently — next poll will correct state.
    }
  }

  /// Seeks forward by the given amount.
  Future<void> seekForward(Duration amount) async {
    await seek(_remotePosition + amount);
  }

  /// Seeks backward by the given amount.
  Future<void> seekBackward(Duration amount) async {
    final target = _remotePosition - amount;
    await seek(target < Duration.zero ? Duration.zero : target);
  }

  /// Stops playback on the remote session.
  Future<void> stop() async {
    stopPolling();
    if (sessionId != null && client != null) {
      try {
        await client!.stop(sessionId!);
      } catch (_) {
        // Best effort.
      }
    }
    sessionId = null;
    _isPlaying = false;
    notifyListeners();
  }

  // ─── Sync Offset Adjustment ────────────────────────────────────────────

  /// Adjusts the sync offset by the given amount.
  ///
  /// Positive = subtitles appear later, Negative = subtitles appear earlier.
  void adjustSyncOffset(Duration delta) {
    _syncOffset += delta;
    notifyListeners();
  }

  /// Sets an absolute sync offset value.
  void setSyncOffset(Duration offset) {
    _syncOffset = offset;
    notifyListeners();
  }

  /// Resets the sync offset to zero.
  void resetSyncOffset() {
    _syncOffset = Duration.zero;
    notifyListeners();
  }

  // ─── Polling Control ───────────────────────────────────────────────────

  /// Sets a custom polling interval.
  ///
  /// Lower values give more responsive sync but more network usage.
  /// Minimum: 200ms, Maximum: 2000ms.
  void setPollInterval(Duration interval) {
    final clamped = interval.inMilliseconds.clamp(200, 2000);
    _pollInterval = Duration(milliseconds: clamped);

    // Restart polling with the new interval if active.
    if (_pollTimer != null) {
      startPolling();
    }
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
