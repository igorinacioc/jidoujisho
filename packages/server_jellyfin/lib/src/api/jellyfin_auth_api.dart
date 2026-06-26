import 'package:dio/dio.dart';
import 'package:server_core/server_core.dart';

/// Jellyfin implementation of [AuthApi].
class JellyfinAuthApi implements AuthApi {
  final Dio _dio;

  JellyfinAuthApi(this._dio);

  @override
  Future<AuthResult> authenticateByName(String username, String password) async {
    final response = await _dio.post(
      '/Users/AuthenticateByName',
      data: {
        'Username': username,
        'Pw': password,
      },
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _dio.post('/Sessions/Logout');
  }
}
