import 'package:flutter/foundation.dart';
import 'package:server_core/server_core.dart';

/// Represents a potential cast target, unifying SSDP-discovered devices
/// and Jellyfin-registered devices into a single model for the picker UI.
class CastTarget {
  /// Human-readable name to display in the device picker.
  final String name;

  /// Short description (e.g. "Google Cast", "Samsung TV", "Jellyfin client").
  final String type;

  /// Icon to show in the device list.
  final CastDeviceIcon icon;

  /// The Jellyfin-registered device, if available (for Jellyfin session casting).
  final ServerDevice? jellyfinDevice;

  /// The SSDP-discovered device, if available (for DLNA/UPnP direct casting).
  final DiscoveredDevice? ssdpDevice;

  const CastTarget({
    required this.name,
    required this.type,
    required this.icon,
    this.jellyfinDevice,
    this.ssdpDevice,
  });

  /// Whether this device supports DLNA direct casting (has SSDP + location URL).
  bool get isDlna => ssdpDevice?.locationUrl != null;

  /// Whether this device supports Jellyfin session casting.
  bool get isJellyfin => jellyfinDevice != null;
}

/// Icon categories for cast devices in the picker UI.
enum CastDeviceIcon {
  cast,
  tv,
  game,
  speaker,
}

/// A device discovered on the local network via SSDP/UPnP.
class DiscoveredDevice {
  final String name;
  final String type;
  final CastDeviceIcon iconType;
  final String ip;
  final String? locationUrl;
  final String? serverInfo;

  const DiscoveredDevice({
    required this.name,
    required this.type,
    required this.iconType,
    required this.ip,
    this.locationUrl,
    this.serverInfo,
  });
}

/// The current state of a cast session.
enum CastSessionState {
  /// No active cast session.
  disconnected,

  /// Connecting to the cast target.
  connecting,

  /// Connected and playing.
  playing,

  /// Connected but paused.
  paused,

  /// Connection lost — attempting to reconnect.
  reconnecting,

  /// Session ended.
  ended,
}

/// Position sync info reported by the cast controller.
class CastPosition {
  /// The remote playback position.
  final Duration remotePosition;

  /// Whether the remote session is currently playing.
  final bool isPlaying;

  /// User-adjustable sync offset to compensate for latency.
  final Duration syncOffset;

  /// Estimated network latency.
  final Duration estimatedLatency;

  /// The synchronization-adjusted position for subtitle matching.
  Duration get syncedPosition {
    final adjusted = remotePosition + syncOffset - estimatedLatency;
    return adjusted < Duration.zero ? Duration.zero : adjusted;
  }

  const CastPosition({
    required this.remotePosition,
    required this.isPlaying,
    this.syncOffset = Duration.zero,
    this.estimatedLatency = const Duration(milliseconds: 150),
  });

  static const empty = CastPosition(
    remotePosition: Duration.zero,
    isPlaying: false,
  );
}

/// Abstract interface for a cast session.
///
/// Both [CastController] (Jellyfin) and [DlnaController] (DLNA/UPnP)
/// implement this interface, so **MiningModePage** can work with either
/// without knowing which one is active.
abstract class CastSession extends ChangeNotifier {
  /// The sync-adjusted position for subtitle matching.
  Duration get syncedPosition;

  /// Whether the session is active (connected to a device).
  bool get isActive;

  /// Whether the remote session is currently playing.
  bool get isPlaying;

  /// User-adjustable sync offset.
  Duration get syncOffset;

  /// Starts position polling.
  void startPolling();

  /// Stops position polling.
  void stopPolling();

  /// Toggles play/pause on the remote session.
  Future<void> playPause();

  /// Seeks to an absolute position.
  Future<void> seek(Duration position);

  /// Seeks forward by a relative amount.
  Future<void> seekForward(Duration amount);

  /// Seeks backward by a relative amount.
  Future<void> seekBackward(Duration amount);

  /// Stops playback and ends the session.
  Future<void> stop();

  /// Adjusts the subtitle sync offset by a delta.
  void adjustSyncOffset(Duration delta);

  /// Resets the sync offset to zero.
  void resetSyncOffset();
}
