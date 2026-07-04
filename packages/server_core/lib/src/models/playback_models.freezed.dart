// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) {
  return _MediaItem.fromJson(json);
}

/// @nodoc
mixin _$MediaItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// The item type (Movie, Episode, Series, Folder, etc.).
  String? get type => throw _privateConstructorUsedError;

  /// Long-form description / synopsis.
  String? get overview => throw _privateConstructorUsedError;

  /// Original title (e.g. Japanese title for anime).
  String? get originalTitle => throw _privateConstructorUsedError;

  /// Available media sources (streamable versions).
  List<MediaSource> get mediaSources => throw _privateConstructorUsedError;

  /// Available media streams (video, audio, subtitle tracks).
  List<MediaStream> get mediaStreams => throw _privateConstructorUsedError;

  /// Duration in ticks (1 tick = 100ns).
  int? get runTimeTicks => throw _privateConstructorUsedError;

  /// Year of production.
  int? get productionYear => throw _privateConstructorUsedError;

  /// Episode number (for episodes).
  int? get indexNumber => throw _privateConstructorUsedError;

  /// Season number (for episodes).
  int? get parentIndexNumber => throw _privateConstructorUsedError;

  /// The parent series ID (for seasons and episodes).
  String? get seriesId => throw _privateConstructorUsedError;

  /// Name of the parent series.
  String? get seriesName => throw _privateConstructorUsedError;

  /// Name of the season.
  String? get seasonName => throw _privateConstructorUsedError;

  /// Image tags keyed by image type (Primary, Backdrop, Logo, etc.).
  Map<String, String> get imageTags => throw _privateConstructorUsedError;

  /// User-specific data (playback position, favorite status, etc.).
  Map<String, dynamic> get userData => throw _privateConstructorUsedError;

  /// Whether this item is a folder/collection (can be browsed into).
  bool? get isFolder => throw _privateConstructorUsedError;

  /// Number of child items (for folders).
  int? get childCount => throw _privateConstructorUsedError;

  /// Backdrop image tags.
  List<String> get backdropImageTags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MediaItemCopyWith<MediaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaItemCopyWith<$Res> {
  factory $MediaItemCopyWith(MediaItem value, $Res Function(MediaItem) then) =
      _$MediaItemCopyWithImpl<$Res, MediaItem>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? type,
      String? overview,
      String? originalTitle,
      List<MediaSource> mediaSources,
      List<MediaStream> mediaStreams,
      int? runTimeTicks,
      int? productionYear,
      int? indexNumber,
      int? parentIndexNumber,
      String? seriesId,
      String? seriesName,
      String? seasonName,
      Map<String, String> imageTags,
      Map<String, dynamic> userData,
      bool? isFolder,
      int? childCount,
      List<String> backdropImageTags});
}

/// @nodoc
class _$MediaItemCopyWithImpl<$Res, $Val extends MediaItem>
    implements $MediaItemCopyWith<$Res> {
  _$MediaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = freezed,
    Object? overview = freezed,
    Object? originalTitle = freezed,
    Object? mediaSources = null,
    Object? mediaStreams = null,
    Object? runTimeTicks = freezed,
    Object? productionYear = freezed,
    Object? indexNumber = freezed,
    Object? parentIndexNumber = freezed,
    Object? seriesId = freezed,
    Object? seriesName = freezed,
    Object? seasonName = freezed,
    Object? imageTags = null,
    Object? userData = null,
    Object? isFolder = freezed,
    Object? childCount = freezed,
    Object? backdropImageTags = null,
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
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      originalTitle: freezed == originalTitle
          ? _value.originalTitle
          : originalTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaSources: null == mediaSources
          ? _value.mediaSources
          : mediaSources // ignore: cast_nullable_to_non_nullable
              as List<MediaSource>,
      mediaStreams: null == mediaStreams
          ? _value.mediaStreams
          : mediaStreams // ignore: cast_nullable_to_non_nullable
              as List<MediaStream>,
      runTimeTicks: freezed == runTimeTicks
          ? _value.runTimeTicks
          : runTimeTicks // ignore: cast_nullable_to_non_nullable
              as int?,
      productionYear: freezed == productionYear
          ? _value.productionYear
          : productionYear // ignore: cast_nullable_to_non_nullable
              as int?,
      indexNumber: freezed == indexNumber
          ? _value.indexNumber
          : indexNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      parentIndexNumber: freezed == parentIndexNumber
          ? _value.parentIndexNumber
          : parentIndexNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      seriesId: freezed == seriesId
          ? _value.seriesId
          : seriesId // ignore: cast_nullable_to_non_nullable
              as String?,
      seriesName: freezed == seriesName
          ? _value.seriesName
          : seriesName // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonName: freezed == seasonName
          ? _value.seasonName
          : seasonName // ignore: cast_nullable_to_non_nullable
              as String?,
      imageTags: null == imageTags
          ? _value.imageTags
          : imageTags // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      userData: null == userData
          ? _value.userData
          : userData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isFolder: freezed == isFolder
          ? _value.isFolder
          : isFolder // ignore: cast_nullable_to_non_nullable
              as bool?,
      childCount: freezed == childCount
          ? _value.childCount
          : childCount // ignore: cast_nullable_to_non_nullable
              as int?,
      backdropImageTags: null == backdropImageTags
          ? _value.backdropImageTags
          : backdropImageTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MediaItemImplCopyWith<$Res>
    implements $MediaItemCopyWith<$Res> {
  factory _$$MediaItemImplCopyWith(
          _$MediaItemImpl value, $Res Function(_$MediaItemImpl) then) =
      __$$MediaItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? type,
      String? overview,
      String? originalTitle,
      List<MediaSource> mediaSources,
      List<MediaStream> mediaStreams,
      int? runTimeTicks,
      int? productionYear,
      int? indexNumber,
      int? parentIndexNumber,
      String? seriesId,
      String? seriesName,
      String? seasonName,
      Map<String, String> imageTags,
      Map<String, dynamic> userData,
      bool? isFolder,
      int? childCount,
      List<String> backdropImageTags});
}

/// @nodoc
class __$$MediaItemImplCopyWithImpl<$Res>
    extends _$MediaItemCopyWithImpl<$Res, _$MediaItemImpl>
    implements _$$MediaItemImplCopyWith<$Res> {
  __$$MediaItemImplCopyWithImpl(
      _$MediaItemImpl _value, $Res Function(_$MediaItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = freezed,
    Object? overview = freezed,
    Object? originalTitle = freezed,
    Object? mediaSources = null,
    Object? mediaStreams = null,
    Object? runTimeTicks = freezed,
    Object? productionYear = freezed,
    Object? indexNumber = freezed,
    Object? parentIndexNumber = freezed,
    Object? seriesId = freezed,
    Object? seriesName = freezed,
    Object? seasonName = freezed,
    Object? imageTags = null,
    Object? userData = null,
    Object? isFolder = freezed,
    Object? childCount = freezed,
    Object? backdropImageTags = null,
  }) {
    return _then(_$MediaItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      originalTitle: freezed == originalTitle
          ? _value.originalTitle
          : originalTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaSources: null == mediaSources
          ? _value._mediaSources
          : mediaSources // ignore: cast_nullable_to_non_nullable
              as List<MediaSource>,
      mediaStreams: null == mediaStreams
          ? _value._mediaStreams
          : mediaStreams // ignore: cast_nullable_to_non_nullable
              as List<MediaStream>,
      runTimeTicks: freezed == runTimeTicks
          ? _value.runTimeTicks
          : runTimeTicks // ignore: cast_nullable_to_non_nullable
              as int?,
      productionYear: freezed == productionYear
          ? _value.productionYear
          : productionYear // ignore: cast_nullable_to_non_nullable
              as int?,
      indexNumber: freezed == indexNumber
          ? _value.indexNumber
          : indexNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      parentIndexNumber: freezed == parentIndexNumber
          ? _value.parentIndexNumber
          : parentIndexNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      seriesId: freezed == seriesId
          ? _value.seriesId
          : seriesId // ignore: cast_nullable_to_non_nullable
              as String?,
      seriesName: freezed == seriesName
          ? _value.seriesName
          : seriesName // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonName: freezed == seasonName
          ? _value.seasonName
          : seasonName // ignore: cast_nullable_to_non_nullable
              as String?,
      imageTags: null == imageTags
          ? _value._imageTags
          : imageTags // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      userData: null == userData
          ? _value._userData
          : userData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isFolder: freezed == isFolder
          ? _value.isFolder
          : isFolder // ignore: cast_nullable_to_non_nullable
              as bool?,
      childCount: freezed == childCount
          ? _value.childCount
          : childCount // ignore: cast_nullable_to_non_nullable
              as int?,
      backdropImageTags: null == backdropImageTags
          ? _value._backdropImageTags
          : backdropImageTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaItemImpl implements _MediaItem {
  const _$MediaItemImpl(
      {required this.id,
      required this.name,
      this.type,
      this.overview,
      this.originalTitle,
      final List<MediaSource> mediaSources = const [],
      final List<MediaStream> mediaStreams = const [],
      this.runTimeTicks,
      this.productionYear,
      this.indexNumber,
      this.parentIndexNumber,
      this.seriesId,
      this.seriesName,
      this.seasonName,
      final Map<String, String> imageTags = const {},
      final Map<String, dynamic> userData = const {},
      this.isFolder,
      this.childCount,
      final List<String> backdropImageTags = const []})
      : _mediaSources = mediaSources,
        _mediaStreams = mediaStreams,
        _imageTags = imageTags,
        _userData = userData,
        _backdropImageTags = backdropImageTags;

  factory _$MediaItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  /// The item type (Movie, Episode, Series, Folder, etc.).
  @override
  final String? type;

  /// Long-form description / synopsis.
  @override
  final String? overview;

  /// Original title (e.g. Japanese title for anime).
  @override
  final String? originalTitle;

  /// Available media sources (streamable versions).
  final List<MediaSource> _mediaSources;

  /// Available media sources (streamable versions).
  @override
  @JsonKey()
  List<MediaSource> get mediaSources {
    if (_mediaSources is EqualUnmodifiableListView) return _mediaSources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaSources);
  }

  /// Available media streams (video, audio, subtitle tracks).
  final List<MediaStream> _mediaStreams;

  /// Available media streams (video, audio, subtitle tracks).
  @override
  @JsonKey()
  List<MediaStream> get mediaStreams {
    if (_mediaStreams is EqualUnmodifiableListView) return _mediaStreams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaStreams);
  }

  /// Duration in ticks (1 tick = 100ns).
  @override
  final int? runTimeTicks;

  /// Year of production.
  @override
  final int? productionYear;

  /// Episode number (for episodes).
  @override
  final int? indexNumber;

  /// Season number (for episodes).
  @override
  final int? parentIndexNumber;

  /// The parent series ID (for seasons and episodes).
  @override
  final String? seriesId;

  /// Name of the parent series.
  @override
  final String? seriesName;

  /// Name of the season.
  @override
  final String? seasonName;

  /// Image tags keyed by image type (Primary, Backdrop, Logo, etc.).
  final Map<String, String> _imageTags;

  /// Image tags keyed by image type (Primary, Backdrop, Logo, etc.).
  @override
  @JsonKey()
  Map<String, String> get imageTags {
    if (_imageTags is EqualUnmodifiableMapView) return _imageTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_imageTags);
  }

  /// User-specific data (playback position, favorite status, etc.).
  final Map<String, dynamic> _userData;

  /// User-specific data (playback position, favorite status, etc.).
  @override
  @JsonKey()
  Map<String, dynamic> get userData {
    if (_userData is EqualUnmodifiableMapView) return _userData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_userData);
  }

  /// Whether this item is a folder/collection (can be browsed into).
  @override
  final bool? isFolder;

  /// Number of child items (for folders).
  @override
  final int? childCount;

  /// Backdrop image tags.
  final List<String> _backdropImageTags;

  /// Backdrop image tags.
  @override
  @JsonKey()
  List<String> get backdropImageTags {
    if (_backdropImageTags is EqualUnmodifiableListView)
      return _backdropImageTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_backdropImageTags);
  }

  @override
  String toString() {
    return 'MediaItem(id: $id, name: $name, type: $type, overview: $overview, originalTitle: $originalTitle, mediaSources: $mediaSources, mediaStreams: $mediaStreams, runTimeTicks: $runTimeTicks, productionYear: $productionYear, indexNumber: $indexNumber, parentIndexNumber: $parentIndexNumber, seriesId: $seriesId, seriesName: $seriesName, seasonName: $seasonName, imageTags: $imageTags, userData: $userData, isFolder: $isFolder, childCount: $childCount, backdropImageTags: $backdropImageTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.originalTitle, originalTitle) ||
                other.originalTitle == originalTitle) &&
            const DeepCollectionEquality()
                .equals(other._mediaSources, _mediaSources) &&
            const DeepCollectionEquality()
                .equals(other._mediaStreams, _mediaStreams) &&
            (identical(other.runTimeTicks, runTimeTicks) ||
                other.runTimeTicks == runTimeTicks) &&
            (identical(other.productionYear, productionYear) ||
                other.productionYear == productionYear) &&
            (identical(other.indexNumber, indexNumber) ||
                other.indexNumber == indexNumber) &&
            (identical(other.parentIndexNumber, parentIndexNumber) ||
                other.parentIndexNumber == parentIndexNumber) &&
            (identical(other.seriesId, seriesId) ||
                other.seriesId == seriesId) &&
            (identical(other.seriesName, seriesName) ||
                other.seriesName == seriesName) &&
            (identical(other.seasonName, seasonName) ||
                other.seasonName == seasonName) &&
            const DeepCollectionEquality()
                .equals(other._imageTags, _imageTags) &&
            const DeepCollectionEquality().equals(other._userData, _userData) &&
            (identical(other.isFolder, isFolder) ||
                other.isFolder == isFolder) &&
            (identical(other.childCount, childCount) ||
                other.childCount == childCount) &&
            const DeepCollectionEquality()
                .equals(other._backdropImageTags, _backdropImageTags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        type,
        overview,
        originalTitle,
        const DeepCollectionEquality().hash(_mediaSources),
        const DeepCollectionEquality().hash(_mediaStreams),
        runTimeTicks,
        productionYear,
        indexNumber,
        parentIndexNumber,
        seriesId,
        seriesName,
        seasonName,
        const DeepCollectionEquality().hash(_imageTags),
        const DeepCollectionEquality().hash(_userData),
        isFolder,
        childCount,
        const DeepCollectionEquality().hash(_backdropImageTags)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaItemImplCopyWith<_$MediaItemImpl> get copyWith =>
      __$$MediaItemImplCopyWithImpl<_$MediaItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaItemImplToJson(
      this,
    );
  }
}

abstract class _MediaItem implements MediaItem {
  const factory _MediaItem(
      {required final String id,
      required final String name,
      final String? type,
      final String? overview,
      final String? originalTitle,
      final List<MediaSource> mediaSources,
      final List<MediaStream> mediaStreams,
      final int? runTimeTicks,
      final int? productionYear,
      final int? indexNumber,
      final int? parentIndexNumber,
      final String? seriesId,
      final String? seriesName,
      final String? seasonName,
      final Map<String, String> imageTags,
      final Map<String, dynamic> userData,
      final bool? isFolder,
      final int? childCount,
      final List<String> backdropImageTags}) = _$MediaItemImpl;

  factory _MediaItem.fromJson(Map<String, dynamic> json) =
      _$MediaItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override

  /// The item type (Movie, Episode, Series, Folder, etc.).
  String? get type;
  @override

  /// Long-form description / synopsis.
  String? get overview;
  @override

  /// Original title (e.g. Japanese title for anime).
  String? get originalTitle;
  @override

  /// Available media sources (streamable versions).
  List<MediaSource> get mediaSources;
  @override

  /// Available media streams (video, audio, subtitle tracks).
  List<MediaStream> get mediaStreams;
  @override

  /// Duration in ticks (1 tick = 100ns).
  int? get runTimeTicks;
  @override

  /// Year of production.
  int? get productionYear;
  @override

  /// Episode number (for episodes).
  int? get indexNumber;
  @override

  /// Season number (for episodes).
  int? get parentIndexNumber;
  @override

  /// The parent series ID (for seasons and episodes).
  String? get seriesId;
  @override

  /// Name of the parent series.
  String? get seriesName;
  @override

  /// Name of the season.
  String? get seasonName;
  @override

  /// Image tags keyed by image type (Primary, Backdrop, Logo, etc.).
  Map<String, String> get imageTags;
  @override

  /// User-specific data (playback position, favorite status, etc.).
  Map<String, dynamic> get userData;
  @override

  /// Whether this item is a folder/collection (can be browsed into).
  bool? get isFolder;
  @override

  /// Number of child items (for folders).
  int? get childCount;
  @override

  /// Backdrop image tags.
  List<String> get backdropImageTags;
  @override
  @JsonKey(ignore: true)
  _$$MediaItemImplCopyWith<_$MediaItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MediaSource _$MediaSourceFromJson(Map<String, dynamic> json) {
  return _MediaSource.fromJson(json);
}

/// @nodoc
mixin _$MediaSource {
  String get id => throw _privateConstructorUsedError;

  /// File path on the server.
  String? get path => throw _privateConstructorUsedError;

  /// Container format (mp4, mkv, etc.).
  String? get container => throw _privateConstructorUsedError;

  /// Bitrate in bits per second.
  int? get bitrate => throw _privateConstructorUsedError;

  /// Whether this source supports direct stream (no transcoding).
  bool? get supportsDirectStream => throw _privateConstructorUsedError;

  /// Whether this source supports transcoding.
  bool? get supportsTranscoding => throw _privateConstructorUsedError;

  /// Source type (Default, etc.).
  String? get type => throw _privateConstructorUsedError;

  /// Human-readable name for this source.
  String? get name => throw _privateConstructorUsedError;

  /// Size of the media file in bytes.
  int? get size => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MediaSourceCopyWith<MediaSource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaSourceCopyWith<$Res> {
  factory $MediaSourceCopyWith(
          MediaSource value, $Res Function(MediaSource) then) =
      _$MediaSourceCopyWithImpl<$Res, MediaSource>;
  @useResult
  $Res call(
      {String id,
      String? path,
      String? container,
      int? bitrate,
      bool? supportsDirectStream,
      bool? supportsTranscoding,
      String? type,
      String? name,
      int? size});
}

/// @nodoc
class _$MediaSourceCopyWithImpl<$Res, $Val extends MediaSource>
    implements $MediaSourceCopyWith<$Res> {
  _$MediaSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = freezed,
    Object? container = freezed,
    Object? bitrate = freezed,
    Object? supportsDirectStream = freezed,
    Object? supportsTranscoding = freezed,
    Object? type = freezed,
    Object? name = freezed,
    Object? size = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as String?,
      bitrate: freezed == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as int?,
      supportsDirectStream: freezed == supportsDirectStream
          ? _value.supportsDirectStream
          : supportsDirectStream // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsTranscoding: freezed == supportsTranscoding
          ? _value.supportsTranscoding
          : supportsTranscoding // ignore: cast_nullable_to_non_nullable
              as bool?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MediaSourceImplCopyWith<$Res>
    implements $MediaSourceCopyWith<$Res> {
  factory _$$MediaSourceImplCopyWith(
          _$MediaSourceImpl value, $Res Function(_$MediaSourceImpl) then) =
      __$$MediaSourceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? path,
      String? container,
      int? bitrate,
      bool? supportsDirectStream,
      bool? supportsTranscoding,
      String? type,
      String? name,
      int? size});
}

/// @nodoc
class __$$MediaSourceImplCopyWithImpl<$Res>
    extends _$MediaSourceCopyWithImpl<$Res, _$MediaSourceImpl>
    implements _$$MediaSourceImplCopyWith<$Res> {
  __$$MediaSourceImplCopyWithImpl(
      _$MediaSourceImpl _value, $Res Function(_$MediaSourceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = freezed,
    Object? container = freezed,
    Object? bitrate = freezed,
    Object? supportsDirectStream = freezed,
    Object? supportsTranscoding = freezed,
    Object? type = freezed,
    Object? name = freezed,
    Object? size = freezed,
  }) {
    return _then(_$MediaSourceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as String?,
      bitrate: freezed == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as int?,
      supportsDirectStream: freezed == supportsDirectStream
          ? _value.supportsDirectStream
          : supportsDirectStream // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsTranscoding: freezed == supportsTranscoding
          ? _value.supportsTranscoding
          : supportsTranscoding // ignore: cast_nullable_to_non_nullable
              as bool?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaSourceImpl implements _MediaSource {
  const _$MediaSourceImpl(
      {required this.id,
      this.path,
      this.container,
      this.bitrate,
      this.supportsDirectStream,
      this.supportsTranscoding,
      this.type,
      this.name,
      this.size});

  factory _$MediaSourceImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaSourceImplFromJson(json);

  @override
  final String id;

  /// File path on the server.
  @override
  final String? path;

  /// Container format (mp4, mkv, etc.).
  @override
  final String? container;

  /// Bitrate in bits per second.
  @override
  final int? bitrate;

  /// Whether this source supports direct stream (no transcoding).
  @override
  final bool? supportsDirectStream;

  /// Whether this source supports transcoding.
  @override
  final bool? supportsTranscoding;

  /// Source type (Default, etc.).
  @override
  final String? type;

  /// Human-readable name for this source.
  @override
  final String? name;

  /// Size of the media file in bytes.
  @override
  final int? size;

  @override
  String toString() {
    return 'MediaSource(id: $id, path: $path, container: $container, bitrate: $bitrate, supportsDirectStream: $supportsDirectStream, supportsTranscoding: $supportsTranscoding, type: $type, name: $name, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaSourceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.container, container) ||
                other.container == container) &&
            (identical(other.bitrate, bitrate) || other.bitrate == bitrate) &&
            (identical(other.supportsDirectStream, supportsDirectStream) ||
                other.supportsDirectStream == supportsDirectStream) &&
            (identical(other.supportsTranscoding, supportsTranscoding) ||
                other.supportsTranscoding == supportsTranscoding) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, path, container, bitrate,
      supportsDirectStream, supportsTranscoding, type, name, size);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaSourceImplCopyWith<_$MediaSourceImpl> get copyWith =>
      __$$MediaSourceImplCopyWithImpl<_$MediaSourceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaSourceImplToJson(
      this,
    );
  }
}

abstract class _MediaSource implements MediaSource {
  const factory _MediaSource(
      {required final String id,
      final String? path,
      final String? container,
      final int? bitrate,
      final bool? supportsDirectStream,
      final bool? supportsTranscoding,
      final String? type,
      final String? name,
      final int? size}) = _$MediaSourceImpl;

  factory _MediaSource.fromJson(Map<String, dynamic> json) =
      _$MediaSourceImpl.fromJson;

  @override
  String get id;
  @override

  /// File path on the server.
  String? get path;
  @override

  /// Container format (mp4, mkv, etc.).
  String? get container;
  @override

  /// Bitrate in bits per second.
  int? get bitrate;
  @override

  /// Whether this source supports direct stream (no transcoding).
  bool? get supportsDirectStream;
  @override

  /// Whether this source supports transcoding.
  bool? get supportsTranscoding;
  @override

  /// Source type (Default, etc.).
  String? get type;
  @override

  /// Human-readable name for this source.
  String? get name;
  @override

  /// Size of the media file in bytes.
  int? get size;
  @override
  @JsonKey(ignore: true)
  _$$MediaSourceImplCopyWith<_$MediaSourceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MediaStream _$MediaStreamFromJson(Map<String, dynamic> json) {
  return _MediaStream.fromJson(json);
}

/// @nodoc
mixin _$MediaStream {
  /// The stream index within the container.
  int get index => throw _privateConstructorUsedError;

  /// Codec name (h264, aac, srt, etc.).
  String? get codec => throw _privateConstructorUsedError;

  /// Human-readable title for this stream.
  String? get displayTitle => throw _privateConstructorUsedError;

  /// Language code (eng, jpn, etc.).
  String? get language => throw _privateConstructorUsedError;

  /// Stream type (Video, Audio, Subtitle).
  String? get type => throw _privateConstructorUsedError;

  /// Whether this is the default track of its type.
  bool? get isDefault => throw _privateConstructorUsedError;

  /// Whether this is an external file.
  bool? get isExternal => throw _privateConstructorUsedError;

  /// For external subtitles, the delivery URL.
  String? get deliveryUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MediaStreamCopyWith<MediaStream> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaStreamCopyWith<$Res> {
  factory $MediaStreamCopyWith(
          MediaStream value, $Res Function(MediaStream) then) =
      _$MediaStreamCopyWithImpl<$Res, MediaStream>;
  @useResult
  $Res call(
      {int index,
      String? codec,
      String? displayTitle,
      String? language,
      String? type,
      bool? isDefault,
      bool? isExternal,
      String? deliveryUrl});
}

/// @nodoc
class _$MediaStreamCopyWithImpl<$Res, $Val extends MediaStream>
    implements $MediaStreamCopyWith<$Res> {
  _$MediaStreamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? codec = freezed,
    Object? displayTitle = freezed,
    Object? language = freezed,
    Object? type = freezed,
    Object? isDefault = freezed,
    Object? isExternal = freezed,
    Object? deliveryUrl = freezed,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      codec: freezed == codec
          ? _value.codec
          : codec // ignore: cast_nullable_to_non_nullable
              as String?,
      displayTitle: freezed == displayTitle
          ? _value.displayTitle
          : displayTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: freezed == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool?,
      isExternal: freezed == isExternal
          ? _value.isExternal
          : isExternal // ignore: cast_nullable_to_non_nullable
              as bool?,
      deliveryUrl: freezed == deliveryUrl
          ? _value.deliveryUrl
          : deliveryUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MediaStreamImplCopyWith<$Res>
    implements $MediaStreamCopyWith<$Res> {
  factory _$$MediaStreamImplCopyWith(
          _$MediaStreamImpl value, $Res Function(_$MediaStreamImpl) then) =
      __$$MediaStreamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int index,
      String? codec,
      String? displayTitle,
      String? language,
      String? type,
      bool? isDefault,
      bool? isExternal,
      String? deliveryUrl});
}

/// @nodoc
class __$$MediaStreamImplCopyWithImpl<$Res>
    extends _$MediaStreamCopyWithImpl<$Res, _$MediaStreamImpl>
    implements _$$MediaStreamImplCopyWith<$Res> {
  __$$MediaStreamImplCopyWithImpl(
      _$MediaStreamImpl _value, $Res Function(_$MediaStreamImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? codec = freezed,
    Object? displayTitle = freezed,
    Object? language = freezed,
    Object? type = freezed,
    Object? isDefault = freezed,
    Object? isExternal = freezed,
    Object? deliveryUrl = freezed,
  }) {
    return _then(_$MediaStreamImpl(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      codec: freezed == codec
          ? _value.codec
          : codec // ignore: cast_nullable_to_non_nullable
              as String?,
      displayTitle: freezed == displayTitle
          ? _value.displayTitle
          : displayTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: freezed == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool?,
      isExternal: freezed == isExternal
          ? _value.isExternal
          : isExternal // ignore: cast_nullable_to_non_nullable
              as bool?,
      deliveryUrl: freezed == deliveryUrl
          ? _value.deliveryUrl
          : deliveryUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaStreamImpl implements _MediaStream {
  const _$MediaStreamImpl(
      {required this.index,
      this.codec,
      this.displayTitle,
      this.language,
      this.type,
      this.isDefault,
      this.isExternal,
      this.deliveryUrl});

  factory _$MediaStreamImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaStreamImplFromJson(json);

  /// The stream index within the container.
  @override
  final int index;

  /// Codec name (h264, aac, srt, etc.).
  @override
  final String? codec;

  /// Human-readable title for this stream.
  @override
  final String? displayTitle;

  /// Language code (eng, jpn, etc.).
  @override
  final String? language;

  /// Stream type (Video, Audio, Subtitle).
  @override
  final String? type;

  /// Whether this is the default track of its type.
  @override
  final bool? isDefault;

  /// Whether this is an external file.
  @override
  final bool? isExternal;

  /// For external subtitles, the delivery URL.
  @override
  final String? deliveryUrl;

  @override
  String toString() {
    return 'MediaStream(index: $index, codec: $codec, displayTitle: $displayTitle, language: $language, type: $type, isDefault: $isDefault, isExternal: $isExternal, deliveryUrl: $deliveryUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaStreamImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.codec, codec) || other.codec == codec) &&
            (identical(other.displayTitle, displayTitle) ||
                other.displayTitle == displayTitle) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isExternal, isExternal) ||
                other.isExternal == isExternal) &&
            (identical(other.deliveryUrl, deliveryUrl) ||
                other.deliveryUrl == deliveryUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, index, codec, displayTitle,
      language, type, isDefault, isExternal, deliveryUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaStreamImplCopyWith<_$MediaStreamImpl> get copyWith =>
      __$$MediaStreamImplCopyWithImpl<_$MediaStreamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaStreamImplToJson(
      this,
    );
  }
}

abstract class _MediaStream implements MediaStream {
  const factory _MediaStream(
      {required final int index,
      final String? codec,
      final String? displayTitle,
      final String? language,
      final String? type,
      final bool? isDefault,
      final bool? isExternal,
      final String? deliveryUrl}) = _$MediaStreamImpl;

  factory _MediaStream.fromJson(Map<String, dynamic> json) =
      _$MediaStreamImpl.fromJson;

  @override

  /// The stream index within the container.
  int get index;
  @override

  /// Codec name (h264, aac, srt, etc.).
  String? get codec;
  @override

  /// Human-readable title for this stream.
  String? get displayTitle;
  @override

  /// Language code (eng, jpn, etc.).
  String? get language;
  @override

  /// Stream type (Video, Audio, Subtitle).
  String? get type;
  @override

  /// Whether this is the default track of its type.
  bool? get isDefault;
  @override

  /// Whether this is an external file.
  bool? get isExternal;
  @override

  /// For external subtitles, the delivery URL.
  String? get deliveryUrl;
  @override
  @JsonKey(ignore: true)
  _$$MediaStreamImplCopyWith<_$MediaStreamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MediaItemExtra _$MediaItemExtraFromJson(Map<String, dynamic> json) {
  return _MediaItemExtra.fromJson(json);
}

/// @nodoc
mixin _$MediaItemExtra {
  /// The media source ID to use for streaming.
  String get mediaSourceId => throw _privateConstructorUsedError;

  /// The server base URL (for constructing stream/image URLs).
  String get serverUrl => throw _privateConstructorUsedError;

  /// Overview/synopsis of the item.
  String? get overview => throw _privateConstructorUsedError;

  /// Parent series name.
  String? get seriesName => throw _privateConstructorUsedError;

  /// Season name.
  String? get seasonName => throw _privateConstructorUsedError;

  /// Episode label (e.g. "S01E05").
  String? get episodeLabel => throw _privateConstructorUsedError;

  /// Item type string from the server.
  String? get itemType => throw _privateConstructorUsedError;

  /// Production year as a string.
  String? get productionYear => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MediaItemExtraCopyWith<MediaItemExtra> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaItemExtraCopyWith<$Res> {
  factory $MediaItemExtraCopyWith(
          MediaItemExtra value, $Res Function(MediaItemExtra) then) =
      _$MediaItemExtraCopyWithImpl<$Res, MediaItemExtra>;
  @useResult
  $Res call(
      {String mediaSourceId,
      String serverUrl,
      String? overview,
      String? seriesName,
      String? seasonName,
      String? episodeLabel,
      String? itemType,
      String? productionYear});
}

/// @nodoc
class _$MediaItemExtraCopyWithImpl<$Res, $Val extends MediaItemExtra>
    implements $MediaItemExtraCopyWith<$Res> {
  _$MediaItemExtraCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaSourceId = null,
    Object? serverUrl = null,
    Object? overview = freezed,
    Object? seriesName = freezed,
    Object? seasonName = freezed,
    Object? episodeLabel = freezed,
    Object? itemType = freezed,
    Object? productionYear = freezed,
  }) {
    return _then(_value.copyWith(
      mediaSourceId: null == mediaSourceId
          ? _value.mediaSourceId
          : mediaSourceId // ignore: cast_nullable_to_non_nullable
              as String,
      serverUrl: null == serverUrl
          ? _value.serverUrl
          : serverUrl // ignore: cast_nullable_to_non_nullable
              as String,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      seriesName: freezed == seriesName
          ? _value.seriesName
          : seriesName // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonName: freezed == seasonName
          ? _value.seasonName
          : seasonName // ignore: cast_nullable_to_non_nullable
              as String?,
      episodeLabel: freezed == episodeLabel
          ? _value.episodeLabel
          : episodeLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      itemType: freezed == itemType
          ? _value.itemType
          : itemType // ignore: cast_nullable_to_non_nullable
              as String?,
      productionYear: freezed == productionYear
          ? _value.productionYear
          : productionYear // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MediaItemExtraImplCopyWith<$Res>
    implements $MediaItemExtraCopyWith<$Res> {
  factory _$$MediaItemExtraImplCopyWith(_$MediaItemExtraImpl value,
          $Res Function(_$MediaItemExtraImpl) then) =
      __$$MediaItemExtraImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String mediaSourceId,
      String serverUrl,
      String? overview,
      String? seriesName,
      String? seasonName,
      String? episodeLabel,
      String? itemType,
      String? productionYear});
}

/// @nodoc
class __$$MediaItemExtraImplCopyWithImpl<$Res>
    extends _$MediaItemExtraCopyWithImpl<$Res, _$MediaItemExtraImpl>
    implements _$$MediaItemExtraImplCopyWith<$Res> {
  __$$MediaItemExtraImplCopyWithImpl(
      _$MediaItemExtraImpl _value, $Res Function(_$MediaItemExtraImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaSourceId = null,
    Object? serverUrl = null,
    Object? overview = freezed,
    Object? seriesName = freezed,
    Object? seasonName = freezed,
    Object? episodeLabel = freezed,
    Object? itemType = freezed,
    Object? productionYear = freezed,
  }) {
    return _then(_$MediaItemExtraImpl(
      mediaSourceId: null == mediaSourceId
          ? _value.mediaSourceId
          : mediaSourceId // ignore: cast_nullable_to_non_nullable
              as String,
      serverUrl: null == serverUrl
          ? _value.serverUrl
          : serverUrl // ignore: cast_nullable_to_non_nullable
              as String,
      overview: freezed == overview
          ? _value.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String?,
      seriesName: freezed == seriesName
          ? _value.seriesName
          : seriesName // ignore: cast_nullable_to_non_nullable
              as String?,
      seasonName: freezed == seasonName
          ? _value.seasonName
          : seasonName // ignore: cast_nullable_to_non_nullable
              as String?,
      episodeLabel: freezed == episodeLabel
          ? _value.episodeLabel
          : episodeLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      itemType: freezed == itemType
          ? _value.itemType
          : itemType // ignore: cast_nullable_to_non_nullable
              as String?,
      productionYear: freezed == productionYear
          ? _value.productionYear
          : productionYear // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaItemExtraImpl implements _MediaItemExtra {
  const _$MediaItemExtraImpl(
      {required this.mediaSourceId,
      required this.serverUrl,
      this.overview,
      this.seriesName,
      this.seasonName,
      this.episodeLabel,
      this.itemType,
      this.productionYear});

  factory _$MediaItemExtraImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaItemExtraImplFromJson(json);

  /// The media source ID to use for streaming.
  @override
  final String mediaSourceId;

  /// The server base URL (for constructing stream/image URLs).
  @override
  final String serverUrl;

  /// Overview/synopsis of the item.
  @override
  final String? overview;

  /// Parent series name.
  @override
  final String? seriesName;

  /// Season name.
  @override
  final String? seasonName;

  /// Episode label (e.g. "S01E05").
  @override
  final String? episodeLabel;

  /// Item type string from the server.
  @override
  final String? itemType;

  /// Production year as a string.
  @override
  final String? productionYear;

  @override
  String toString() {
    return 'MediaItemExtra(mediaSourceId: $mediaSourceId, serverUrl: $serverUrl, overview: $overview, seriesName: $seriesName, seasonName: $seasonName, episodeLabel: $episodeLabel, itemType: $itemType, productionYear: $productionYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaItemExtraImpl &&
            (identical(other.mediaSourceId, mediaSourceId) ||
                other.mediaSourceId == mediaSourceId) &&
            (identical(other.serverUrl, serverUrl) ||
                other.serverUrl == serverUrl) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.seriesName, seriesName) ||
                other.seriesName == seriesName) &&
            (identical(other.seasonName, seasonName) ||
                other.seasonName == seasonName) &&
            (identical(other.episodeLabel, episodeLabel) ||
                other.episodeLabel == episodeLabel) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.productionYear, productionYear) ||
                other.productionYear == productionYear));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, mediaSourceId, serverUrl,
      overview, seriesName, seasonName, episodeLabel, itemType, productionYear);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaItemExtraImplCopyWith<_$MediaItemExtraImpl> get copyWith =>
      __$$MediaItemExtraImplCopyWithImpl<_$MediaItemExtraImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaItemExtraImplToJson(
      this,
    );
  }
}

abstract class _MediaItemExtra implements MediaItemExtra {
  const factory _MediaItemExtra(
      {required final String mediaSourceId,
      required final String serverUrl,
      final String? overview,
      final String? seriesName,
      final String? seasonName,
      final String? episodeLabel,
      final String? itemType,
      final String? productionYear}) = _$MediaItemExtraImpl;

  factory _MediaItemExtra.fromJson(Map<String, dynamic> json) =
      _$MediaItemExtraImpl.fromJson;

  @override

  /// The media source ID to use for streaming.
  String get mediaSourceId;
  @override

  /// The server base URL (for constructing stream/image URLs).
  String get serverUrl;
  @override

  /// Overview/synopsis of the item.
  String? get overview;
  @override

  /// Parent series name.
  String? get seriesName;
  @override

  /// Season name.
  String? get seasonName;
  @override

  /// Episode label (e.g. "S01E05").
  String? get episodeLabel;
  @override

  /// Item type string from the server.
  String? get itemType;
  @override

  /// Production year as a string.
  String? get productionYear;
  @override
  @JsonKey(ignore: true)
  _$$MediaItemExtraImplCopyWith<_$MediaItemExtraImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
