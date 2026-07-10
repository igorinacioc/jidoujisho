// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceInfoImpl _$$DeviceInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeviceInfoImpl(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      clientName: json['clientName'] as String,
      clientVersion: json['clientVersion'] as String,
    );

Map<String, dynamic> _$$DeviceInfoImplToJson(_$DeviceInfoImpl instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'clientName': instance.clientName,
      'clientVersion': instance.clientVersion,
    };

_$ServerDeviceImpl _$$ServerDeviceImplFromJson(Map<String, dynamic> json) =>
    _$ServerDeviceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      appName: json['appName'] as String?,
      lastUserName: json['lastUserName'] as String?,
      lastActivityDate: json['lastActivityDate'] == null
          ? null
          : DateTime.parse(json['lastActivityDate'] as String),
      iconUrl: json['iconUrl'] as String?,
    );

Map<String, dynamic> _$$ServerDeviceImplToJson(_$ServerDeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'appName': instance.appName,
      'lastUserName': instance.lastUserName,
      'lastActivityDate': instance.lastActivityDate?.toIso8601String(),
      'iconUrl': instance.iconUrl,
    };

_$SessionInfoImpl _$$SessionInfoImplFromJson(Map<String, dynamic> json) =>
    _$SessionInfoImpl(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      client: json['client'] as String?,
      isPaused: (json['isPaused'] as bool?) ?? false,
      positionTicks: (json['positionTicks'] as num?)?.toInt() ?? 0,
      nowPlayingItemId: json['nowPlayingItemId'] as String?,
      nowPlayingItemName: json['nowPlayingItemName'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$SessionInfoImplToJson(_$SessionInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'client': instance.client,
      'isPaused': instance.isPaused,
      'positionTicks': instance.positionTicks,
      'nowPlayingItemId': instance.nowPlayingItemId,
      'nowPlayingItemName': instance.nowPlayingItemName,
      'userId': instance.userId,
      'userName': instance.userName,
    };

_$PlayStateImpl _$$PlayStateImplFromJson(Map<String, dynamic> json) =>
    _$PlayStateImpl(
      isPaused: json['isPaused'] as bool,
      positionTicks: (json['positionTicks'] as num).toInt(),
      isMuted: json['isMuted'] as bool?,
      volumeLevel: (json['volumeLevel'] as num?)?.toInt(),
      playMethod: json['playMethod'] as String?,
      repeatMode: json['repeatMode'] as String?,
    );

Map<String, dynamic> _$$PlayStateImplToJson(_$PlayStateImpl instance) =>
    <String, dynamic>{
      'isPaused': instance.isPaused,
      'positionTicks': instance.positionTicks,
      'isMuted': instance.isMuted,
      'volumeLevel': instance.volumeLevel,
      'playMethod': instance.playMethod,
      'repeatMode': instance.repeatMode,
    };
