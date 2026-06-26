// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthResult {
  String get accessToken => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get serverId => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;
  String? get serverName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AuthResultCopyWith<AuthResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultCopyWith<$Res> {
  factory $AuthResultCopyWith(
          AuthResult value, $Res Function(AuthResult) then) =
      _$AuthResultCopyWithImpl<$Res, AuthResult>;
  @useResult
  $Res call(
      {String accessToken,
      String userId,
      String serverId,
      String? userName,
      String? serverName});
}

/// @nodoc
class _$AuthResultCopyWithImpl<$Res, $Val extends AuthResult>
    implements $AuthResultCopyWith<$Res> {
  _$AuthResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? userId = null,
    Object? serverId = null,
    Object? userName = freezed,
    Object? serverName = freezed,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      serverName: freezed == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthResultImplCopyWith<$Res>
    implements $AuthResultCopyWith<$Res> {
  factory _$$AuthResultImplCopyWith(
          _$AuthResultImpl value, $Res Function(_$AuthResultImpl) then) =
      __$$AuthResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accessToken,
      String userId,
      String serverId,
      String? userName,
      String? serverName});
}

/// @nodoc
class __$$AuthResultImplCopyWithImpl<$Res>
    extends _$AuthResultCopyWithImpl<$Res, _$AuthResultImpl>
    implements _$$AuthResultImplCopyWith<$Res> {
  __$$AuthResultImplCopyWithImpl(
      _$AuthResultImpl _value, $Res Function(_$AuthResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? userId = null,
    Object? serverId = null,
    Object? userName = freezed,
    Object? serverName = freezed,
  }) {
    return _then(_$AuthResultImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      serverName: freezed == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AuthResultImpl implements _AuthResult {
  const _$AuthResultImpl(
      {required this.accessToken,
      required this.userId,
      required this.serverId,
      this.userName,
      this.serverName});

  @override
  final String accessToken;
  @override
  final String userId;
  @override
  final String serverId;
  @override
  final String? userName;
  @override
  final String? serverName;

  @override
  String toString() {
    return 'AuthResult(accessToken: $accessToken, userId: $userId, serverId: $serverId, userName: $userName, serverName: $serverName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, accessToken, userId, serverId, userName, serverName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      __$$AuthResultImplCopyWithImpl<_$AuthResultImpl>(this, _$identity);
}

abstract class _AuthResult implements AuthResult {
  const factory _AuthResult(
      {required final String accessToken,
      required final String userId,
      required final String serverId,
      final String? userName,
      final String? serverName}) = _$AuthResultImpl;

  @override
  String get accessToken;
  @override
  String get userId;
  @override
  String get serverId;
  @override
  String? get userName;
  @override
  String? get serverName;
  @override
  @JsonKey(ignore: true)
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return _UserInfo.fromJson(json);
}

/// @nodoc
mixin _$UserInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool? get hasPassword => throw _privateConstructorUsedError;
  bool? get isAdministrator => throw _privateConstructorUsedError;
  DateTime? get lastLoginDate => throw _privateConstructorUsedError;
  DateTime? get lastActivityDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserInfoCopyWith<UserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserInfoCopyWith<$Res> {
  factory $UserInfoCopyWith(UserInfo value, $Res Function(UserInfo) then) =
      _$UserInfoCopyWithImpl<$Res, UserInfo>;
  @useResult
  $Res call(
      {String id,
      String name,
      bool? hasPassword,
      bool? isAdministrator,
      DateTime? lastLoginDate,
      DateTime? lastActivityDate});
}

/// @nodoc
class _$UserInfoCopyWithImpl<$Res, $Val extends UserInfo>
    implements $UserInfoCopyWith<$Res> {
  _$UserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? hasPassword = freezed,
    Object? isAdministrator = freezed,
    Object? lastLoginDate = freezed,
    Object? lastActivityDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      hasPassword: freezed == hasPassword
          ? _value.hasPassword
          : hasPassword // ignore: cast_nullable_to_non_nullable
              as bool?,
      isAdministrator: freezed == isAdministrator
          ? _value.isAdministrator
          : isAdministrator // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastLoginDate: freezed == lastLoginDate
          ? _value.lastLoginDate
          : lastLoginDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActivityDate: freezed == lastActivityDate
          ? _value.lastActivityDate
          : lastActivityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserInfoImplCopyWith<$Res>
    implements $UserInfoCopyWith<$Res> {
  factory _$$UserInfoImplCopyWith(
          _$UserInfoImpl value, $Res Function(_$UserInfoImpl) then) =
      __$$UserInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      bool? hasPassword,
      bool? isAdministrator,
      DateTime? lastLoginDate,
      DateTime? lastActivityDate});
}

/// @nodoc
class __$$UserInfoImplCopyWithImpl<$Res>
    extends _$UserInfoCopyWithImpl<$Res, _$UserInfoImpl>
    implements _$$UserInfoImplCopyWith<$Res> {
  __$$UserInfoImplCopyWithImpl(
      _$UserInfoImpl _value, $Res Function(_$UserInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? hasPassword = freezed,
    Object? isAdministrator = freezed,
    Object? lastLoginDate = freezed,
    Object? lastActivityDate = freezed,
  }) {
    return _then(_$UserInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      hasPassword: freezed == hasPassword
          ? _value.hasPassword
          : hasPassword // ignore: cast_nullable_to_non_nullable
              as bool?,
      isAdministrator: freezed == isAdministrator
          ? _value.isAdministrator
          : isAdministrator // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastLoginDate: freezed == lastLoginDate
          ? _value.lastLoginDate
          : lastLoginDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActivityDate: freezed == lastActivityDate
          ? _value.lastActivityDate
          : lastActivityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserInfoImpl implements _UserInfo {
  const _$UserInfoImpl(
      {required this.id,
      required this.name,
      this.hasPassword,
      this.isAdministrator,
      this.lastLoginDate,
      this.lastActivityDate});

  factory _$UserInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final bool? hasPassword;
  @override
  final bool? isAdministrator;
  @override
  final DateTime? lastLoginDate;
  @override
  final DateTime? lastActivityDate;

  @override
  String toString() {
    return 'UserInfo(id: $id, name: $name, hasPassword: $hasPassword, isAdministrator: $isAdministrator, lastLoginDate: $lastLoginDate, lastActivityDate: $lastActivityDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.hasPassword, hasPassword) ||
                other.hasPassword == hasPassword) &&
            (identical(other.isAdministrator, isAdministrator) ||
                other.isAdministrator == isAdministrator) &&
            (identical(other.lastLoginDate, lastLoginDate) ||
                other.lastLoginDate == lastLoginDate) &&
            (identical(other.lastActivityDate, lastActivityDate) ||
                other.lastActivityDate == lastActivityDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, hasPassword,
      isAdministrator, lastLoginDate, lastActivityDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserInfoImplCopyWith<_$UserInfoImpl> get copyWith =>
      __$$UserInfoImplCopyWithImpl<_$UserInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserInfoImplToJson(
      this,
    );
  }
}

abstract class _UserInfo implements UserInfo {
  const factory _UserInfo(
      {required final String id,
      required final String name,
      final bool? hasPassword,
      final bool? isAdministrator,
      final DateTime? lastLoginDate,
      final DateTime? lastActivityDate}) = _$UserInfoImpl;

  factory _UserInfo.fromJson(Map<String, dynamic> json) =
      _$UserInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  bool? get hasPassword;
  @override
  bool? get isAdministrator;
  @override
  DateTime? get lastLoginDate;
  @override
  DateTime? get lastActivityDate;
  @override
  @JsonKey(ignore: true)
  _$$UserInfoImplCopyWith<_$UserInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) {
  return _ServerInfo.fromJson(json);
}

/// @nodoc
mixin _$ServerInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  String? get operatingSystem => throw _privateConstructorUsedError;
  bool? get supportsSyncPlay => throw _privateConstructorUsedError;
  bool? get supportsLiveTv => throw _privateConstructorUsedError;
  bool? get supportsDownloads => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServerInfoCopyWith<ServerInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerInfoCopyWith<$Res> {
  factory $ServerInfoCopyWith(
          ServerInfo value, $Res Function(ServerInfo) then) =
      _$ServerInfoCopyWithImpl<$Res, ServerInfo>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? version,
      String? operatingSystem,
      bool? supportsSyncPlay,
      bool? supportsLiveTv,
      bool? supportsDownloads});
}

/// @nodoc
class _$ServerInfoCopyWithImpl<$Res, $Val extends ServerInfo>
    implements $ServerInfoCopyWith<$Res> {
  _$ServerInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? version = freezed,
    Object? operatingSystem = freezed,
    Object? supportsSyncPlay = freezed,
    Object? supportsLiveTv = freezed,
    Object? supportsDownloads = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      operatingSystem: freezed == operatingSystem
          ? _value.operatingSystem
          : operatingSystem // ignore: cast_nullable_to_non_nullable
              as String?,
      supportsSyncPlay: freezed == supportsSyncPlay
          ? _value.supportsSyncPlay
          : supportsSyncPlay // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsLiveTv: freezed == supportsLiveTv
          ? _value.supportsLiveTv
          : supportsLiveTv // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsDownloads: freezed == supportsDownloads
          ? _value.supportsDownloads
          : supportsDownloads // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServerInfoImplCopyWith<$Res>
    implements $ServerInfoCopyWith<$Res> {
  factory _$$ServerInfoImplCopyWith(
          _$ServerInfoImpl value, $Res Function(_$ServerInfoImpl) then) =
      __$$ServerInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? version,
      String? operatingSystem,
      bool? supportsSyncPlay,
      bool? supportsLiveTv,
      bool? supportsDownloads});
}

/// @nodoc
class __$$ServerInfoImplCopyWithImpl<$Res>
    extends _$ServerInfoCopyWithImpl<$Res, _$ServerInfoImpl>
    implements _$$ServerInfoImplCopyWith<$Res> {
  __$$ServerInfoImplCopyWithImpl(
      _$ServerInfoImpl _value, $Res Function(_$ServerInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? version = freezed,
    Object? operatingSystem = freezed,
    Object? supportsSyncPlay = freezed,
    Object? supportsLiveTv = freezed,
    Object? supportsDownloads = freezed,
  }) {
    return _then(_$ServerInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      operatingSystem: freezed == operatingSystem
          ? _value.operatingSystem
          : operatingSystem // ignore: cast_nullable_to_non_nullable
              as String?,
      supportsSyncPlay: freezed == supportsSyncPlay
          ? _value.supportsSyncPlay
          : supportsSyncPlay // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsLiveTv: freezed == supportsLiveTv
          ? _value.supportsLiveTv
          : supportsLiveTv // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsDownloads: freezed == supportsDownloads
          ? _value.supportsDownloads
          : supportsDownloads // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServerInfoImpl implements _ServerInfo {
  const _$ServerInfoImpl(
      {required this.id,
      required this.name,
      this.version,
      this.operatingSystem,
      this.supportsSyncPlay,
      this.supportsLiveTv,
      this.supportsDownloads});

  factory _$ServerInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServerInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? version;
  @override
  final String? operatingSystem;
  @override
  final bool? supportsSyncPlay;
  @override
  final bool? supportsLiveTv;
  @override
  final bool? supportsDownloads;

  @override
  String toString() {
    return 'ServerInfo(id: $id, name: $name, version: $version, operatingSystem: $operatingSystem, supportsSyncPlay: $supportsSyncPlay, supportsLiveTv: $supportsLiveTv, supportsDownloads: $supportsDownloads)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.operatingSystem, operatingSystem) ||
                other.operatingSystem == operatingSystem) &&
            (identical(other.supportsSyncPlay, supportsSyncPlay) ||
                other.supportsSyncPlay == supportsSyncPlay) &&
            (identical(other.supportsLiveTv, supportsLiveTv) ||
                other.supportsLiveTv == supportsLiveTv) &&
            (identical(other.supportsDownloads, supportsDownloads) ||
                other.supportsDownloads == supportsDownloads));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, version,
      operatingSystem, supportsSyncPlay, supportsLiveTv, supportsDownloads);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerInfoImplCopyWith<_$ServerInfoImpl> get copyWith =>
      __$$ServerInfoImplCopyWithImpl<_$ServerInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServerInfoImplToJson(
      this,
    );
  }
}

abstract class _ServerInfo implements ServerInfo {
  const factory _ServerInfo(
      {required final String id,
      required final String name,
      final String? version,
      final String? operatingSystem,
      final bool? supportsSyncPlay,
      final bool? supportsLiveTv,
      final bool? supportsDownloads}) = _$ServerInfoImpl;

  factory _ServerInfo.fromJson(Map<String, dynamic> json) =
      _$ServerInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get version;
  @override
  String? get operatingSystem;
  @override
  bool? get supportsSyncPlay;
  @override
  bool? get supportsLiveTv;
  @override
  bool? get supportsDownloads;
  @override
  @JsonKey(ignore: true)
  _$$ServerInfoImplCopyWith<_$ServerInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
