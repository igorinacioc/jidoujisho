import 'package:dio/dio.dart';

import '../models/device_models.dart';
import 'auth_header.dart';

/// Creates a pre-configured [Dio] instance for communicating with a media server.
///
/// Sets up:
/// - Base URL pointing to the server
/// - No automatic redirect following (the redirect interceptor handles this)
/// - Standard timeouts
/// - Auth header injection
Dio configureServerDio({
  required String baseUrl,
  required DeviceInfo deviceInfo,
  String? accessToken,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 10),
    followRedirects: false,
    validateStatus: (status) =>
        status != null && status < 500, // Let 4xx through for error handling
  ));

  // Auth interceptor — attaches the X-Emby-Authorization header.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['X-Emby-Authorization'] = buildAuthHeader(
        deviceInfo: deviceInfo,
        accessToken: accessToken,
      );
      options.headers['Content-Type'] = 'application/json';
      handler.next(options);
    },
  ));

  return dio;
}
