/// Server core abstraction layer.
///
/// Provides abstract interfaces for media server communication,
/// supporting multiple backends (Jellyfin, Emby).
///
/// The app programs against the abstractions defined here.
/// Concrete implementations live in separate packages
/// (e.g., [server_jellyfin]).
library;

// ─── Core ─────────────────────────────────────────────────────────────────
export 'src/media_server_client.dart';

// ─── Models ───────────────────────────────────────────────────────────────
export 'src/models/server_type.dart';
export 'src/models/device_models.dart';
export 'src/models/playback_models.dart';
export 'src/models/server_models.dart';
export 'src/models/enums.dart';

// ─── API Contracts ────────────────────────────────────────────────────────
export 'src/api/auth_api.dart';
export 'src/api/items_api.dart';
export 'src/api/playback_api.dart';
export 'src/api/session_api.dart';
export 'src/api/image_api.dart';
export 'src/api/user_library_api.dart';
export 'src/api/user_views_api.dart';

// ─── Network ──────────────────────────────────────────────────────────────
export 'src/network/auth_header.dart';
export 'src/network/configure_server_dio.dart';
