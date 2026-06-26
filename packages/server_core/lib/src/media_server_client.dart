import 'api/auth_api.dart';
import 'api/image_api.dart';
import 'api/items_api.dart';
import 'api/playback_api.dart';
import 'api/session_api.dart';
import 'api/user_library_api.dart';
import 'api/user_views_api.dart';
import 'models/device_models.dart';
import 'models/server_type.dart';

/// Abstract media server client.
///
/// Defines the contract that all server implementations must fulfill.
/// The app programs against this interface, never against a concrete
/// implementation. This enables:
///
/// - Swapping Jellyfin for Emby by injecting a different implementation
/// - Supporting multiple servers simultaneously
/// - Mocking the entire server layer for unit tests
///
/// Implementations:
/// - [JellyfinMediaServerClient] in `package:server_jellyfin`
abstract class MediaServerClient {
  // ─── Server Identity ────────────────────────────────────────────────────

  /// The type of media server this client connects to.
  ServerType get serverType;

  /// The base URL of the server (e.g. http://192.168.1.100:8096).
  String get baseUrl;

  // ─── Authentication State ───────────────────────────────────────────────

  /// The current access token, if authenticated.
  String? get accessToken;

  /// The current user ID, if authenticated.
  String? get userId;

  /// Information about this client device.
  DeviceInfo get deviceInfo;

  // ─── API Endpoints ──────────────────────────────────────────────────────

  /// Authentication (login/logout).
  AuthApi get authApi;

  /// Library browsing and search.
  ItemsApi get itemsApi;

  /// Streaming URLs and progress reporting.
  PlaybackApi get playbackApi;

  /// Device listing and remote playback control (casting).
  SessionApi get sessionApi;

  /// Image URL construction.
  ImageApi get imageApi;

  /// User library — recently added, favorites, play status.
  UserLibraryApi get userLibraryApi;

  /// User views — top-level library folders.
  UserViewsApi get userViewsApi;

  // ─── Lifecycle ──────────────────────────────────────────────────────────

  /// Releases resources held by this client.
  void dispose();
}
