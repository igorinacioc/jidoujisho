// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) {
  return _DeviceInfo.fromJson(json);
}

/// @nodoc
mixin _$DeviceInfo {
  /// Unique identifier for this device.
  String get deviceId => throw _privateConstructorUsedError;

  /// Human-readable device name.
  String get deviceName => throw _privateConstructorUsedError;

  /// The client application name.
  String get clientName => throw _privateConstructorUsedError;

  /// Client version string.
  String get clientVersion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeviceInfoCopyWith<DeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceInfoCopyWith<$Res> {
  factory $DeviceInfoCopyWith(
          DeviceInfo value, $Res Function(DeviceInfo) then) =
      _$DeviceInfoCopyWithImpl<$Res, DeviceInfo>;
  @useResult
  $Res call(
      {String deviceId,
      String deviceName,
      String clientName,
      String clientVersion});
}

/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res, $Val extends DeviceInfo>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? deviceName = null,
    Object? clientName = null,
    Object? clientVersion = null,
  }) {
    return _then(_value.copyWith(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      clientVersion: null == clientVersion
          ? _value.clientVersion
          : clientVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceInfoImplCopyWith<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  factory _$$DeviceInfoImplCopyWith(
          _$DeviceInfoImpl value, $Res Function(_$DeviceInfoImpl) then) =
      __$$DeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String deviceId,
      String deviceName,
      String clientName,
      String clientVersion});
}

/// @nodoc
class __$$DeviceInfoImplCopyWithImpl<$Res>
    extends _$DeviceInfoCopyWithImpl<$Res, _$DeviceInfoImpl>
    implements _$$DeviceInfoImplCopyWith<$Res> {
  __$$DeviceInfoImplCopyWithImpl(
      _$DeviceInfoImpl _value, $Res Function(_$DeviceInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? deviceName = null,
    Object? clientName = null,
    Object? clientVersion = null,
  }) {
    return _then(_$DeviceInfoImpl(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      clientVersion: null == clientVersion
          ? _value.clientVersion
          : clientVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceInfoImpl implements _DeviceInfo {
  const _$DeviceInfoImpl(
      {required this.deviceId,
      required this.deviceName,
      required this.clientName,
      required this.clientVersion});

  factory _$DeviceInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceInfoImplFromJson(json);

  /// Unique identifier for this device.
  @override
  final String deviceId;

  /// Human-readable device name.
  @override
  final String deviceName;

  /// The client application name.
  @override
  final String clientName;

  /// Client version string.
  @override
  final String clientVersion;

  @override
  String toString() {
    return 'DeviceInfo(deviceId: $deviceId, deviceName: $deviceName, clientName: $clientName, clientVersion: $clientVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceInfoImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.clientVersion, clientVersion) ||
                other.clientVersion == clientVersion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, deviceId, deviceName, clientName, clientVersion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      __$$DeviceInfoImplCopyWithImpl<_$DeviceInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceInfoImplToJson(
      this,
    );
  }
}

abstract class _DeviceInfo implements DeviceInfo {
  const factory _DeviceInfo(
      {required final String deviceId,
      required final String deviceName,
      required final String clientName,
      required final String clientVersion}) = _$DeviceInfoImpl;

  factory _DeviceInfo.fromJson(Map<String, dynamic> json) =
      _$DeviceInfoImpl.fromJson;

  @override

  /// Unique identifier for this device.
  String get deviceId;
  @override

  /// Human-readable device name.
  String get deviceName;
  @override

  /// The client application name.
  String get clientName;
  @override

  /// Client version string.
  String get clientVersion;
  @override
  @JsonKey(ignore: true)
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ServerDevice _$ServerDeviceFromJson(Map<String, dynamic> json) {
  return _ServerDevice.fromJson(json);
}

/// @nodoc
mixin _$ServerDevice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// The app/browser name this device uses to connect.
  String? get appName => throw _privateConstructorUsedError;

  /// The last user who used this device.
  String? get lastUserName => throw _privateConstructorUsedError;

  /// When this device was last active.
  DateTime? get lastActivityDate => throw _privateConstructorUsedError;

  /// URL to the device's icon.
  String? get iconUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServerDeviceCopyWith<ServerDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerDeviceCopyWith<$Res> {
  factory $ServerDeviceCopyWith(
          ServerDevice value, $Res Function(ServerDevice) then) =
      _$ServerDeviceCopyWithImpl<$Res, ServerDevice>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? appName,
      String? lastUserName,
      DateTime? lastActivityDate,
      String? iconUrl});
}

/// @nodoc
class _$ServerDeviceCopyWithImpl<$Res, $Val extends ServerDevice>
    implements $ServerDeviceCopyWith<$Res> {
  _$ServerDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? appName = freezed,
    Object? lastUserName = freezed,
    Object? lastActivityDate = freezed,
    Object? iconUrl = freezed,
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
      appName: freezed == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUserName: freezed == lastUserName
          ? _value.lastUserName
          : lastUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActivityDate: freezed == lastActivityDate
          ? _value.lastActivityDate
          : lastActivityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServerDeviceImplCopyWith<$Res>
    implements $ServerDeviceCopyWith<$Res> {
  factory _$$ServerDeviceImplCopyWith(
          _$ServerDeviceImpl value, $Res Function(_$ServerDeviceImpl) then) =
      __$$ServerDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? appName,
      String? lastUserName,
      DateTime? lastActivityDate,
      String? iconUrl});
}

/// @nodoc
class __$$ServerDeviceImplCopyWithImpl<$Res>
    extends _$ServerDeviceCopyWithImpl<$Res, _$ServerDeviceImpl>
    implements _$$ServerDeviceImplCopyWith<$Res> {
  __$$ServerDeviceImplCopyWithImpl(
      _$ServerDeviceImpl _value, $Res Function(_$ServerDeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? appName = freezed,
    Object? lastUserName = freezed,
    Object? lastActivityDate = freezed,
    Object? iconUrl = freezed,
  }) {
    return _then(_$ServerDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      appName: freezed == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUserName: freezed == lastUserName
          ? _value.lastUserName
          : lastUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActivityDate: freezed == lastActivityDate
          ? _value.lastActivityDate
          : lastActivityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServerDeviceImpl implements _ServerDevice {
  const _$ServerDeviceImpl(
      {required this.id,
      required this.name,
      this.appName,
      this.lastUserName,
      this.lastActivityDate,
      this.iconUrl});

  factory _$ServerDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServerDeviceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  /// The app/browser name this device uses to connect.
  @override
  final String? appName;

  /// The last user who used this device.
  @override
  final String? lastUserName;

  /// When this device was last active.
  @override
  final DateTime? lastActivityDate;

  /// URL to the device's icon.
  @override
  final String? iconUrl;

  @override
  String toString() {
    return 'ServerDevice(id: $id, name: $name, appName: $appName, lastUserName: $lastUserName, lastActivityDate: $lastActivityDate, iconUrl: $iconUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.appName, appName) || other.appName == appName) &&
            (identical(other.lastUserName, lastUserName) ||
                other.lastUserName == lastUserName) &&
            (identical(other.lastActivityDate, lastActivityDate) ||
                other.lastActivityDate == lastActivityDate) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, appName, lastUserName, lastActivityDate, iconUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerDeviceImplCopyWith<_$ServerDeviceImpl> get copyWith =>
      __$$ServerDeviceImplCopyWithImpl<_$ServerDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServerDeviceImplToJson(
      this,
    );
  }
}

abstract class _ServerDevice implements ServerDevice {
  const factory _ServerDevice(
      {required final String id,
      required final String name,
      final String? appName,
      final String? lastUserName,
      final DateTime? lastActivityDate,
      final String? iconUrl}) = _$ServerDeviceImpl;

  factory _ServerDevice.fromJson(Map<String, dynamic> json) =
      _$ServerDeviceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override

  /// The app/browser name this device uses to connect.
  String? get appName;
  @override

  /// The last user who used this device.
  String? get lastUserName;
  @override

  /// When this device was last active.
  DateTime? get lastActivityDate;
  @override

  /// URL to the device's icon.
  String? get iconUrl;
  @override
  @JsonKey(ignore: true)
  _$$ServerDeviceImplCopyWith<_$ServerDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionInfo _$SessionInfoFromJson(Map<String, dynamic> json) {
  return _SessionInfo.fromJson(json);
}

/// @nodoc
mixin _$SessionInfo {
  String get id => throw _privateConstructorUsedError;

  /// The device this session is playing on.
  String get deviceId => throw _privateConstructorUsedError;

  /// Human-readable device name.
  String get deviceName => throw _privateConstructorUsedError;

  /// The client application name.
  String? get client => throw _privateConstructorUsedError;

  /// Whether playback is currently paused.
  bool get isPaused => throw _privateConstructorUsedError;

  /// Current playback position in ticks (1 tick = 100ns).
  int get positionTicks => throw _privateConstructorUsedError;

  /// The ID of the item currently playing.
  String? get nowPlayingItemId => throw _privateConstructorUsedError;

  /// The name of the item currently playing.
  String? get nowPlayingItemName => throw _privateConstructorUsedError;

  /// The user who owns this session.
  String? get userId => throw _privateConstructorUsedError;

  /// The user name who owns this session.
  String? get userName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SessionInfoCopyWith<SessionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionInfoCopyWith<$Res> {
  factory $SessionInfoCopyWith(
          SessionInfo value, $Res Function(SessionInfo) then) =
      _$SessionInfoCopyWithImpl<$Res, SessionInfo>;
  @useResult
  $Res call(
      {String id,
      String deviceId,
      String deviceName,
      String? client,
      bool isPaused,
      int positionTicks,
      String? nowPlayingItemId,
      String? nowPlayingItemName,
      String? userId,
      String? userName});
}

/// @nodoc
class _$SessionInfoCopyWithImpl<$Res, $Val extends SessionInfo>
    implements $SessionInfoCopyWith<$Res> {
  _$SessionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? deviceName = null,
    Object? client = freezed,
    Object? isPaused = null,
    Object? positionTicks = null,
    Object? nowPlayingItemId = freezed,
    Object? nowPlayingItemName = freezed,
    Object? userId = freezed,
    Object? userName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      client: freezed == client
          ? _value.client
          : client // ignore: cast_nullable_to_non_nullable
              as String?,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      positionTicks: null == positionTicks
          ? _value.positionTicks
          : positionTicks // ignore: cast_nullable_to_non_nullable
              as int,
      nowPlayingItemId: freezed == nowPlayingItemId
          ? _value.nowPlayingItemId
          : nowPlayingItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      nowPlayingItemName: freezed == nowPlayingItemName
          ? _value.nowPlayingItemName
          : nowPlayingItemName // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionInfoImplCopyWith<$Res>
    implements $SessionInfoCopyWith<$Res> {
  factory _$$SessionInfoImplCopyWith(
          _$SessionInfoImpl value, $Res Function(_$SessionInfoImpl) then) =
      __$$SessionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deviceId,
      String deviceName,
      String? client,
      bool isPaused,
      int positionTicks,
      String? nowPlayingItemId,
      String? nowPlayingItemName,
      String? userId,
      String? userName});
}

/// @nodoc
class __$$SessionInfoImplCopyWithImpl<$Res>
    extends _$SessionInfoCopyWithImpl<$Res, _$SessionInfoImpl>
    implements _$$SessionInfoImplCopyWith<$Res> {
  __$$SessionInfoImplCopyWithImpl(
      _$SessionInfoImpl _value, $Res Function(_$SessionInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? deviceName = null,
    Object? client = freezed,
    Object? isPaused = null,
    Object? positionTicks = null,
    Object? nowPlayingItemId = freezed,
    Object? nowPlayingItemName = freezed,
    Object? userId = freezed,
    Object? userName = freezed,
  }) {
    return _then(_$SessionInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      client: freezed == client
          ? _value.client
          : client // ignore: cast_nullable_to_non_nullable
              as String?,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      positionTicks: null == positionTicks
          ? _value.positionTicks
          : positionTicks // ignore: cast_nullable_to_non_nullable
              as int,
      nowPlayingItemId: freezed == nowPlayingItemId
          ? _value.nowPlayingItemId
          : nowPlayingItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      nowPlayingItemName: freezed == nowPlayingItemName
          ? _value.nowPlayingItemName
          : nowPlayingItemName // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionInfoImpl implements _SessionInfo {
  const _$SessionInfoImpl(
      {required this.id,
      required this.deviceId,
      required this.deviceName,
      this.client,
      this.isPaused = false,
      this.positionTicks = 0,
      this.nowPlayingItemId,
      this.nowPlayingItemName,
      this.userId,
      this.userName});

  factory _$SessionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionInfoImplFromJson(json);

  @override
  final String id;

  /// The device this session is playing on.
  @override
  final String deviceId;

  /// Human-readable device name.
  @override
  final String deviceName;

  /// The client application name.
  @override
  final String? client;

  /// Whether playback is currently paused.
  @override
  final bool isPaused;

  /// Current playback position in ticks (1 tick = 100ns).
  @override
  final int positionTicks;

  /// The ID of the item currently playing.
  @override
  final String? nowPlayingItemId;

  /// The name of the item currently playing.
  @override
  final String? nowPlayingItemName;

  /// The user who owns this session.
  @override
  final String? userId;

  /// The user name who owns this session.
  @override
  final String? userName;

  @override
  String toString() {
    return 'SessionInfo(id: $id, deviceId: $deviceId, deviceName: $deviceName, client: $client, isPaused: $isPaused, positionTicks: $positionTicks, nowPlayingItemId: $nowPlayingItemId, nowPlayingItemName: $nowPlayingItemName, userId: $userId, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.client, client) || other.client == client) &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.positionTicks, positionTicks) ||
                other.positionTicks == positionTicks) &&
            (identical(other.nowPlayingItemId, nowPlayingItemId) ||
                other.nowPlayingItemId == nowPlayingItemId) &&
            (identical(other.nowPlayingItemName, nowPlayingItemName) ||
                other.nowPlayingItemName == nowPlayingItemName) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      deviceId,
      deviceName,
      client,
      isPaused,
      positionTicks,
      nowPlayingItemId,
      nowPlayingItemName,
      userId,
      userName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionInfoImplCopyWith<_$SessionInfoImpl> get copyWith =>
      __$$SessionInfoImplCopyWithImpl<_$SessionInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionInfoImplToJson(
      this,
    );
  }
}

abstract class _SessionInfo implements SessionInfo {
  const factory _SessionInfo(
      {required final String id,
      required final String deviceId,
      required final String deviceName,
      final String? client,
      final bool isPaused,
      final int positionTicks,
      final String? nowPlayingItemId,
      final String? nowPlayingItemName,
      final String? userId,
      final String? userName}) = _$SessionInfoImpl;

  factory _SessionInfo.fromJson(Map<String, dynamic> json) =
      _$SessionInfoImpl.fromJson;

  @override
  String get id;
  @override

  /// The device this session is playing on.
  String get deviceId;
  @override

  /// Human-readable device name.
  String get deviceName;
  @override

  /// The client application name.
  String? get client;
  @override

  /// Whether playback is currently paused.
  bool get isPaused;
  @override

  /// Current playback position in ticks (1 tick = 100ns).
  int get positionTicks;
  @override

  /// The ID of the item currently playing.
  String? get nowPlayingItemId;
  @override

  /// The name of the item currently playing.
  String? get nowPlayingItemName;
  @override

  /// The user who owns this session.
  String? get userId;
  @override

  /// The user name who owns this session.
  String? get userName;
  @override
  @JsonKey(ignore: true)
  _$$SessionInfoImplCopyWith<_$SessionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayState _$PlayStateFromJson(Map<String, dynamic> json) {
  return _PlayState.fromJson(json);
}

/// @nodoc
mixin _$PlayState {
  bool get isPaused => throw _privateConstructorUsedError;
  int get positionTicks => throw _privateConstructorUsedError;
  bool? get isMuted => throw _privateConstructorUsedError;
  int? get volumeLevel => throw _privateConstructorUsedError;
  String? get playMethod => throw _privateConstructorUsedError;
  String? get repeatMode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlayStateCopyWith<PlayState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayStateCopyWith<$Res> {
  factory $PlayStateCopyWith(PlayState value, $Res Function(PlayState) then) =
      _$PlayStateCopyWithImpl<$Res, PlayState>;
  @useResult
  $Res call(
      {bool isPaused,
      int positionTicks,
      bool? isMuted,
      int? volumeLevel,
      String? playMethod,
      String? repeatMode});
}

/// @nodoc
class _$PlayStateCopyWithImpl<$Res, $Val extends PlayState>
    implements $PlayStateCopyWith<$Res> {
  _$PlayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPaused = null,
    Object? positionTicks = null,
    Object? isMuted = freezed,
    Object? volumeLevel = freezed,
    Object? playMethod = freezed,
    Object? repeatMode = freezed,
  }) {
    return _then(_value.copyWith(
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      positionTicks: null == positionTicks
          ? _value.positionTicks
          : positionTicks // ignore: cast_nullable_to_non_nullable
              as int,
      isMuted: freezed == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool?,
      volumeLevel: freezed == volumeLevel
          ? _value.volumeLevel
          : volumeLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      playMethod: freezed == playMethod
          ? _value.playMethod
          : playMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      repeatMode: freezed == repeatMode
          ? _value.repeatMode
          : repeatMode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayStateImplCopyWith<$Res>
    implements $PlayStateCopyWith<$Res> {
  factory _$$PlayStateImplCopyWith(
          _$PlayStateImpl value, $Res Function(_$PlayStateImpl) then) =
      __$$PlayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPaused,
      int positionTicks,
      bool? isMuted,
      int? volumeLevel,
      String? playMethod,
      String? repeatMode});
}

/// @nodoc
class __$$PlayStateImplCopyWithImpl<$Res>
    extends _$PlayStateCopyWithImpl<$Res, _$PlayStateImpl>
    implements _$$PlayStateImplCopyWith<$Res> {
  __$$PlayStateImplCopyWithImpl(
      _$PlayStateImpl _value, $Res Function(_$PlayStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPaused = null,
    Object? positionTicks = null,
    Object? isMuted = freezed,
    Object? volumeLevel = freezed,
    Object? playMethod = freezed,
    Object? repeatMode = freezed,
  }) {
    return _then(_$PlayStateImpl(
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      positionTicks: null == positionTicks
          ? _value.positionTicks
          : positionTicks // ignore: cast_nullable_to_non_nullable
              as int,
      isMuted: freezed == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool?,
      volumeLevel: freezed == volumeLevel
          ? _value.volumeLevel
          : volumeLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      playMethod: freezed == playMethod
          ? _value.playMethod
          : playMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      repeatMode: freezed == repeatMode
          ? _value.repeatMode
          : repeatMode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayStateImpl implements _PlayState {
  const _$PlayStateImpl(
      {required this.isPaused,
      required this.positionTicks,
      this.isMuted,
      this.volumeLevel,
      this.playMethod,
      this.repeatMode});

  factory _$PlayStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayStateImplFromJson(json);

  @override
  final bool isPaused;
  @override
  final int positionTicks;
  @override
  final bool? isMuted;
  @override
  final int? volumeLevel;
  @override
  final String? playMethod;
  @override
  final String? repeatMode;

  @override
  String toString() {
    return 'PlayState(isPaused: $isPaused, positionTicks: $positionTicks, isMuted: $isMuted, volumeLevel: $volumeLevel, playMethod: $playMethod, repeatMode: $repeatMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayStateImpl &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.positionTicks, positionTicks) ||
                other.positionTicks == positionTicks) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.volumeLevel, volumeLevel) ||
                other.volumeLevel == volumeLevel) &&
            (identical(other.playMethod, playMethod) ||
                other.playMethod == playMethod) &&
            (identical(other.repeatMode, repeatMode) ||
                other.repeatMode == repeatMode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, isPaused, positionTicks, isMuted,
      volumeLevel, playMethod, repeatMode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayStateImplCopyWith<_$PlayStateImpl> get copyWith =>
      __$$PlayStateImplCopyWithImpl<_$PlayStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayStateImplToJson(
      this,
    );
  }
}

abstract class _PlayState implements PlayState {
  const factory _PlayState(
      {required final bool isPaused,
      required final int positionTicks,
      final bool? isMuted,
      final int? volumeLevel,
      final String? playMethod,
      final String? repeatMode}) = _$PlayStateImpl;

  factory _PlayState.fromJson(Map<String, dynamic> json) =
      _$PlayStateImpl.fromJson;

  @override
  bool get isPaused;
  @override
  int get positionTicks;
  @override
  bool? get isMuted;
  @override
  int? get volumeLevel;
  @override
  String? get playMethod;
  @override
  String? get repeatMode;
  @override
  @JsonKey(ignore: true)
  _$$PlayStateImplCopyWith<_$PlayStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
