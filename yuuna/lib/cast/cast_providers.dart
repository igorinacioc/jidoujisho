import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server_core/server_core.dart';
import 'package:server_jellyfin/server_jellyfin.dart';

import 'cast_controller.dart';
import 'cast_models.dart';
import 'device_discovery.dart';

// ─── Server Client Provider ──────────────────────────────────────────────

/// The active Jellyfin media server client.
///
/// Created when the user connects to a server, disposed on disconnect.
/// All Jellyfin operations flow through this single client.
final jellyfinClientProvider = StateProvider<JellyfinMediaServerClient?>((ref) {
  return null;
});

// ─── Service Providers (read from client) ────────────────────────────────

/// Session API — for device listing and remote playback control.
final sessionApiProvider = Provider<SessionApi?>((ref) {
  return ref.watch(jellyfinClientProvider)?.sessionApi;
});

/// Playback API — for stream URLs and subtitle retrieval.
final playbackApiProvider = Provider<PlaybackApi?>((ref) {
  return ref.watch(jellyfinClientProvider)?.playbackApi;
});

/// Items API — for library browsing and search.
final itemsApiProvider = Provider<ItemsApi?>((ref) {
  return ref.watch(jellyfinClientProvider)?.itemsApi;
});

/// Auth API — for login/logout.
final authApiProvider = Provider<AuthApi?>((ref) {
  return ref.watch(jellyfinClientProvider)?.authApi;
});

// ─── Discovery ───────────────────────────────────────────────────────────

/// Device discovery service — created on demand.
final deviceDiscoveryProvider = Provider<DeviceDiscovery?>((ref) {
  final sessionApi = ref.watch(sessionApiProvider);
  if (sessionApi == null) return null;
  return DeviceDiscovery(sessionApi);
});

// ─── Active Cast Session ─────────────────────────────────────────────────

/// The currently active cast controller, if any.
///
/// Created when the user starts a cast session, disposed when
/// the session ends or the user leaves mining mode.
///
/// Note: This can be either a [CastController] (Jellyfin)
/// or a [DlnaController] (DLNA/UPnP direct).
final activeCastControllerProvider =
    StateProvider<ChangeNotifier?>((ref) {
  return null;
});

// ─── Helpers ─────────────────────────────────────────────────────────────

/// Creates a [JellyfinMediaServerClient] from saved credentials.
JellyfinMediaServerClient? createClientFromCredentials({
  required String serverUrl,
  required String accessToken,
  required String userId,
}) {
  final deviceId = 'yuuna-${DateTime.now().millisecondsSinceEpoch}';
  final client = JellyfinMediaServerClient(
    baseUrl: serverUrl,
    deviceInfo: DeviceInfo(
      deviceId: deviceId,
      deviceName: 'Yuuna',
      clientName: 'Yuuna',
      clientVersion: '2.9.0',
    ),
  );
  client.setCredentials(accessToken: accessToken, userId: userId);
  return client;
}
