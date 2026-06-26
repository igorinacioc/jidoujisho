import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_models.freezed.dart';
part 'server_models.g.dart';

/// Result of a successful authentication.
///
/// Handles Jellyfin API response:
/// ```json
/// {"AccessToken": "...", "ServerId": "...", "User": {"Id": "...", "Name": "..."}}
/// ```
@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult({
    required String accessToken,
    required String userId,
    required String serverId,
    String? userName,
    String? serverName,
  }) = _AuthResult;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    // After pascalToCamelCase transform: {accessToken, serverId, user: {id, name}}
    final user = json['user'] as Map<String, dynamic>?;
    return AuthResult(
      accessToken: json['accessToken'] as String? ?? '',
      userId: user?['id'] as String? ?? '',
      serverId: json['serverId'] as String? ?? '',
      userName: user?['name'] as String?,
      serverName: json['serverName'] as String?,
    );
  }
}

/// Basic information about a media server user.
@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String id,
    required String name,
    bool? hasPassword,
    bool? isAdministrator,
    DateTime? lastLoginDate,
    DateTime? lastActivityDate,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
}

/// General-purpose server information.
@freezed
class ServerInfo with _$ServerInfo {
  const factory ServerInfo({
    required String id,
    required String name,
    String? version,
    String? operatingSystem,
    bool? supportsSyncPlay,
    bool? supportsLiveTv,
    bool? supportsDownloads,
  }) = _ServerInfo;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}
