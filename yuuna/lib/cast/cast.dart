/// Cast module — device discovery, session management, and
/// subtitle-synchronized remote playback ("Cast + Mine").
///
/// Architecture:
/// ```
/// UI (MiningModePage, DevicePicker)
///   → CastController / DlnaController / ChromecastController (ChangeNotifier)
///     → SessionApi (abstract)                (server_core)
///       → JellyfinSessionApi (concrete)       (server_jellyfin)
///     → CastV2Connection + CastCorsProxy      (in-house CastV2 protocol)
///       → Chromecast device (mDNS discovery + TLS/8009)
/// ```
///
/// The app never imports `server_jellyfin` directly — it programs
/// against `server_core` abstractions. DI wires the concrete impl.
library;

export 'cast_controller.dart';
export 'cast_cors_proxy.dart';
export 'cast_models.dart';
export 'cast_providers.dart';
export 'castv2_protocol.dart';
export 'chromecast_controller.dart';
export 'chromecast_discovery.dart';
export 'device_discovery.dart';
export 'device_picker.dart';
export 'dlna_controller.dart';
export 'dlna_discovery_service.dart';
export 'multicast_lock.dart';
export 'player_controller_adapter.dart';
export 'subtitle_service.dart';
