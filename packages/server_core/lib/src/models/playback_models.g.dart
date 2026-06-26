// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MediaItemImpl _$$MediaItemImplFromJson(Map<String, dynamic> json) =>
    _$MediaItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String?,
      overview: json['overview'] as String?,
      originalTitle: json['originalTitle'] as String?,
      mediaSources: (json['mediaSources'] as List<dynamic>?)
              ?.map((e) => MediaSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mediaStreams: (json['mediaStreams'] as List<dynamic>?)
              ?.map((e) => MediaStream.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      runTimeTicks: (json['runTimeTicks'] as num?)?.toInt(),
      productionYear: (json['productionYear'] as num?)?.toInt(),
      indexNumber: (json['indexNumber'] as num?)?.toInt(),
      parentIndexNumber: json['parentIndexNumber'] as String?,
      seriesId: json['seriesId'] as String?,
      seriesName: json['seriesName'] as String?,
      seasonName: json['seasonName'] as String?,
      imageTags: (json['imageTags'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      userData: json['userData'] as Map<String, dynamic>? ?? const {},
      isFolder: json['isFolder'] as bool?,
      childCount: (json['childCount'] as num?)?.toInt(),
      backdropImageTags: (json['backdropImageTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MediaItemImplToJson(_$MediaItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'overview': instance.overview,
      'originalTitle': instance.originalTitle,
      'mediaSources': instance.mediaSources,
      'mediaStreams': instance.mediaStreams,
      'runTimeTicks': instance.runTimeTicks,
      'productionYear': instance.productionYear,
      'indexNumber': instance.indexNumber,
      'parentIndexNumber': instance.parentIndexNumber,
      'seriesId': instance.seriesId,
      'seriesName': instance.seriesName,
      'seasonName': instance.seasonName,
      'imageTags': instance.imageTags,
      'userData': instance.userData,
      'isFolder': instance.isFolder,
      'childCount': instance.childCount,
      'backdropImageTags': instance.backdropImageTags,
    };

_$MediaSourceImpl _$$MediaSourceImplFromJson(Map<String, dynamic> json) =>
    _$MediaSourceImpl(
      id: json['id'] as String,
      path: json['path'] as String?,
      container: json['container'] as String?,
      bitrate: (json['bitrate'] as num?)?.toInt(),
      supportsDirectStream: json['supportsDirectStream'] as bool?,
      supportsTranscoding: json['supportsTranscoding'] as bool?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      size: (json['size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$MediaSourceImplToJson(_$MediaSourceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'container': instance.container,
      'bitrate': instance.bitrate,
      'supportsDirectStream': instance.supportsDirectStream,
      'supportsTranscoding': instance.supportsTranscoding,
      'type': instance.type,
      'name': instance.name,
      'size': instance.size,
    };

_$MediaStreamImpl _$$MediaStreamImplFromJson(Map<String, dynamic> json) =>
    _$MediaStreamImpl(
      index: (json['index'] as num).toInt(),
      codec: json['codec'] as String?,
      displayTitle: json['displayTitle'] as String?,
      language: json['language'] as String?,
      type: json['type'] as String?,
      isDefault: json['isDefault'] as bool?,
      isExternal: json['isExternal'] as bool?,
      deliveryUrl: json['deliveryUrl'] as String?,
    );

Map<String, dynamic> _$$MediaStreamImplToJson(_$MediaStreamImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'codec': instance.codec,
      'displayTitle': instance.displayTitle,
      'language': instance.language,
      'type': instance.type,
      'isDefault': instance.isDefault,
      'isExternal': instance.isExternal,
      'deliveryUrl': instance.deliveryUrl,
    };

_$MediaItemExtraImpl _$$MediaItemExtraImplFromJson(Map<String, dynamic> json) =>
    _$MediaItemExtraImpl(
      mediaSourceId: json['mediaSourceId'] as String,
      serverUrl: json['serverUrl'] as String,
      overview: json['overview'] as String?,
      seriesName: json['seriesName'] as String?,
      seasonName: json['seasonName'] as String?,
      episodeLabel: json['episodeLabel'] as String?,
      itemType: json['itemType'] as String?,
      productionYear: json['productionYear'] as String?,
    );

Map<String, dynamic> _$$MediaItemExtraImplToJson(
        _$MediaItemExtraImpl instance) =>
    <String, dynamic>{
      'mediaSourceId': instance.mediaSourceId,
      'serverUrl': instance.serverUrl,
      'overview': instance.overview,
      'seriesName': instance.seriesName,
      'seasonName': instance.seasonName,
      'episodeLabel': instance.episodeLabel,
      'itemType': instance.itemType,
      'productionYear': instance.productionYear,
    };
