import '../models/device_models.dart';

/// Builds the X-Emby-Authorization header used by both Jellyfin and Emby.
///
/// Format:
/// ```
/// MediaBrowser Client="appName", Device="deviceName",
///   DeviceId="deviceId", Version="version"[, Token="token"]
/// ```
String buildAuthHeader({
  required DeviceInfo deviceInfo,
  String? accessToken,
}) {
  final buffer = StringBuffer('MediaBrowser ');
  buffer.write('Client="${deviceInfo.clientName}", ');
  buffer.write('Device="${deviceInfo.deviceName}", ');
  buffer.write('DeviceId="${deviceInfo.deviceId}", ');
  buffer.write('Version="${deviceInfo.clientVersion}"');

  if (accessToken != null && accessToken.isNotEmpty) {
    buffer.write(', Token="$accessToken"');
  }

  return buffer.toString();
}
