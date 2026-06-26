import '../models/device_models.dart';

/// Session API contract — device listing and remote playback control.
///
/// This is the core of the "Cast" functionality: listing
/// cast-capable devices, sending playback commands, and
/// monitoring remote sessions.
abstract class SessionApi {
  /// Gets all active sessions on the server.
  Future<List<SessionInfo>> getSessions();

  /// Gets the session for a specific device.
  Future<SessionInfo?> getSession(String deviceId);

  /// Gets all registered devices on the server.
  Future<List<ServerDevice>> getDevices();

  /// Starts playback of a media item on a specific device.
  ///
  /// [itemId] is the media to play.
  /// [mediaSourceId] is the media source to use.
  /// [deviceId] is the target device.
  /// Returns the session ID if successful.
  Future<String?> startPlayback(
    String itemId,
    String mediaSourceId,
    String deviceId,
  );

  /// Sends a playback command to a session.
  ///
  /// [command] is one of: Play, Pause, Stop, Seek, PlayPause.
  /// [seekTicks] is required for Seek commands (1 tick = 100ns).
  Future<void> sendCommand(
    String sessionId,
    String command, {
    int? seekTicks,
  });

  /// Sends a play command.
  Future<void> play(String sessionId);

  /// Sends a pause command.
  Future<void> pause(String sessionId);

  /// Sends a stop command.
  Future<void> stop(String sessionId);

  /// Sends a seek command.
  Future<void> seek(String sessionId, Duration position);
}
