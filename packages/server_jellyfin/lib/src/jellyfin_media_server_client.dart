import 'package:dio/dio.dart';
import 'package:server_core/server_core.dart';

import 'api/jellyfin_auth_api.dart';
import 'api/jellyfin_image_api.dart';
import 'api/jellyfin_items_api.dart';
import 'api/jellyfin_playback_api.dart';
import 'api/jellyfin_session_api.dart';
import 'api/jellyfin_user_library_api.dart';
import 'api/jellyfin_user_views_api.dart';
import 'jellyfin_response_transformer.dart';

/// Jellyfin implementation of [MediaServerClient].
///
/// Wires together all Jellyfin API implementations using a shared [Dio] instance.
/// The Dio instance is configured with auth interception so every request
/// automatically carries the X-Emby-Authorization header.
class JellyfinMediaServerClient extends MediaServerClient {
  @override
  final ServerType serverType = ServerType.jellyfin;

  @override
  final DeviceInfo deviceInfo;

  late final Dio _dio;

  String? _accessToken;
  String? _userId;
  String _baseUrl;

  // ─── API instances ─────────────────────────────────────────────────────

  @override
  late final JellyfinAuthApi authApi;

  @override
  late final JellyfinItemsApi itemsApi;

  @override
  late final JellyfinPlaybackApi playbackApi;

  @override
  late final JellyfinSessionApi sessionApi;

  @override
  late final JellyfinImageApi imageApi;

  @override
  late final JellyfinUserLibraryApi userLibraryApi;

  @override
  late final JellyfinUserViewsApi userViewsApi;

  // ─── Constructor ───────────────────────────────────────────────────────

  JellyfinMediaServerClient({
    required String baseUrl,
    required this.deviceInfo,
    String? accessToken,
    String? userId,
  }) : _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
      _accessToken = accessToken,
      _userId = userId {
    _dio = _configureDio();
    _createApis();
  }

  Dio _configureDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: false,
      validateStatus: (status) => status != null && status < 500,
    ));

    // Auth interceptor.
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-Emby-Authorization'] = buildAuthHeader(
          deviceInfo: deviceInfo,
          accessToken: _accessToken,
        );
        handler.next(options);
      },
      // Convert PascalCase Jellyfin responses to camelCase for freezed.
      // Only transforms JSON responses — plain text (subtitles, etc.) passes through.
      onResponse: (response, handler) {
        if (response.data is Map<String, dynamic>) {
          response.data = pascalToCamelCase(response.data as Map<String, dynamic>);
        } else if (response.data is List) {
          response.data = (response.data as List)
              .map((e) => e is Map<String, dynamic> ? pascalToCamelCase(e) : e)
              .toList();
        }
        handler.next(response);
      },
    ));

    return dio;
  }

  void _createApis() {
    authApi = JellyfinAuthApi(_dio);
    itemsApi = JellyfinItemsApi(_dio, () => _userId!);
    playbackApi = JellyfinPlaybackApi(_dio, _baseUrl, () => _accessToken!);
    sessionApi = JellyfinSessionApi(_dio);
    imageApi = JellyfinImageApi(_baseUrl);
    userLibraryApi = JellyfinUserLibraryApi(_dio, () => _userId!);
    userViewsApi = JellyfinUserViewsApi(_dio, () => _userId!);
  }

  // ─── Getters / Setters ─────────────────────────────────────────────────

  @override
  String get baseUrl => _baseUrl;

  @override
  String? get accessToken => _accessToken;

  @override
  String? get userId => _userId;

  /// Sets the auth credentials (e.g. from saved session).
  void setCredentials({required String accessToken, required String userId}) {
    _accessToken = accessToken;
    _userId = userId;
  }

  /// Updates the access token after authentication.
  void setAccessToken(String token) => _accessToken = token;

  /// Updates the user ID after authentication.
  void setUserId(String id) => _userId = id;

  // ─── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void dispose() {
    _dio.close();
  }
}
