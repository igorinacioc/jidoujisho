import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_models.freezed.dart';
part 'device_models.g.dart';

/// Information about this client device, sent to the server.
@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    /// Unique identifier for this device.
    required String deviceId,

    /// Human-readable device name.
    required String deviceName,

    /// The client application name.
    required String clientName,

    /// Client version string.
    required String clientVersion,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

/// A device registered on the server (potential cast targets).
@freezed
class ServerDevice with _$ServerDevice {
  const factory ServerDevice({
    required String id,
    required String name,

    /// The app/browser name this device uses to connect.
    String? appName,

    /// The last user who used this device.
    String? lastUserName,

    /// When this device was last active.
    DateTime? lastActivityDate,

    /// URL to the device's icon.
    String? iconUrl,
  }) = _ServerDevice;

  factory ServerDevice.fromJson(Map<String, dynamic> json) =>
      _$ServerDeviceFromJson(json);
}

/// A playback session on the server.
@freezed
class SessionInfo with _$SessionInfo {
  const factory SessionInfo({
    required String id,

    /// The device this session is playing on.
    required String deviceId,

    /// Human-readable device name.
    required String deviceName,

    /// The client application name.
    String? client,

    /// Whether playback is currently paused.
    /// Null-safe: Jellyfin returns null for newly created sessions.
    @JsonKey(defaultValue: false)
    @Default(false) bool isPaused,

    /// Current playback position in ticks (1 tick = 100ns).
    /// Null-safe: Jellyfin returns null for newly created sessions.
    @JsonKey(defaultValue: 0)
    @Default(0) int positionTicks,

    /// The ID of the item currently playing.
    String? nowPlayingItemId,

    /// The name of the item currently playing.
    String? nowPlayingItemName,

    /// The user who owns this session.
    String? userId,

    /// The user name who owns this session.
    String? userName,
  }) = _SessionInfo;

  factory SessionInfo.fromJson(Map<String, dynamic> json) =>
      _$SessionInfoFromJson(json);
}

/// Play state within a session.
@freezed
class PlayState with _$PlayState {
  const factory PlayState({
    required bool isPaused,
    required int positionTicks,
    bool? isMuted,
    int? volumeLevel,
    String? playMethod,
    String? repeatMode,
  }) = _PlayState;

  factory PlayState.fromJson(Map<String, dynamic> json) =>
      _$PlayStateFromJson(json);
}
