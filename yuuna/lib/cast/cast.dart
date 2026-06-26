/// Cast module — device discovery, session management, and
/// subtitle-synchronized remote playback ("Cast + Mine").
///
/// Architecture:
/// ```
/// UI (MiningModePage, DevicePicker)
///   → CastController / DlnaController  (ChangeNotifier)
///     → SessionApi (abstract)          (server_core)
///       → JellyfinSessionApi (concrete)(server_jellyfin)
/// ```
///
/// The app never imports `server_jellyfin` directly — it programs
/// against `server_core` abstractions. DI wires the concrete impl.
library;

export 'cast_controller.dart';
export 'cast_models.dart';
export 'cast_providers.dart';
export 'device_discovery.dart';
export 'device_picker.dart';
export 'dlna_controller.dart';
export 'subtitle_service.dart';
export 'media_kit_player_service.dart';
export 'player_controller_adapter.dart';
