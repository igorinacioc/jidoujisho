// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserInfoImpl _$$UserInfoImplFromJson(Map<String, dynamic> json) =>
    _$UserInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      hasPassword: json['hasPassword'] as bool?,
      isAdministrator: json['isAdministrator'] as bool?,
      lastLoginDate: json['lastLoginDate'] == null
          ? null
          : DateTime.parse(json['lastLoginDate'] as String),
      lastActivityDate: json['lastActivityDate'] == null
          ? null
          : DateTime.parse(json['lastActivityDate'] as String),
    );

Map<String, dynamic> _$$UserInfoImplToJson(_$UserInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hasPassword': instance.hasPassword,
      'isAdministrator': instance.isAdministrator,
      'lastLoginDate': instance.lastLoginDate?.toIso8601String(),
      'lastActivityDate': instance.lastActivityDate?.toIso8601String(),
    };

_$ServerInfoImpl _$$ServerInfoImplFromJson(Map<String, dynamic> json) =>
    _$ServerInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String?,
      operatingSystem: json['operatingSystem'] as String?,
      supportsSyncPlay: json['supportsSyncPlay'] as bool?,
      supportsLiveTv: json['supportsLiveTv'] as bool?,
      supportsDownloads: json['supportsDownloads'] as bool?,
    );

Map<String, dynamic> _$$ServerInfoImplToJson(_$ServerInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'operatingSystem': instance.operatingSystem,
      'supportsSyncPlay': instance.supportsSyncPlay,
      'supportsLiveTv': instance.supportsLiveTv,
      'supportsDownloads': instance.supportsDownloads,
    };
