/// Data models for Jellyfin API responses.
///
/// These models represent the JSON structures returned by the Jellyfin REST API.
class JellyfinItem {
  final String id;
  final String name;
  final String? originalTitle;
  final String? overview;
  final String? type;
  final List<JellyfinMediaSource>? mediaSources;
  final List<JellyfinMediaStream>? mediaStreams;
  final int? runTimeTicks;
  final int? productionYear;
  final int? indexNumber;
  final String? parentIndexNumber;
  final String? seriesName;
  final String? seasonName;
  final Map<String, String>? imageTags;
  final Map<String, dynamic>? userData;
  final bool? isFolder;

  JellyfinItem({
    required this.id,
    required this.name,
    this.originalTitle,
    this.overview,
    this.type,
    this.mediaSources,
    this.mediaStreams,
    this.runTimeTicks,
    this.productionYear,
    this.indexNumber,
    this.parentIndexNumber,
    this.seriesName,
    this.seasonName,
    this.imageTags,
    this.userData,
    this.isFolder,
  });

  factory JellyfinItem.fromJson(Map<String, dynamic> json) {
    return JellyfinItem(
      id: json['Id'] as String? ?? '',
      name: json['Name'] as String? ?? 'Unknown',
      originalTitle: json['OriginalTitle'] as String?,
      overview: json['Overview'] as String?,
      type: json['Type'] as String?,
      mediaSources: (json['MediaSources'] as List<dynamic>?)
          ?.map((e) => JellyfinMediaSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      mediaStreams: (json['MediaStreams'] as List<dynamic>?)
          ?.map((e) => JellyfinMediaStream.fromJson(e as Map<String, dynamic>))
          .toList(),
      runTimeTicks: json['RunTimeTicks'] as int?,
      productionYear: json['ProductionYear'] as int?,
      indexNumber: json['IndexNumber'] as int?,
      parentIndexNumber: json['ParentIndexNumber'] as String?,
      seriesName: json['SeriesName'] as String?,
      seasonName: json['SeasonName'] as String?,
      imageTags: json['ImageTags'] != null
          ? Map<String, String>.from(json['ImageTags'] as Map)
          : null,
      userData: json['UserData'] as Map<String, dynamic>?,
      isFolder: json['IsFolder'] as bool?,
    );
  }

  /// Returns the duration of this item as a [Duration], or null if unknown.
  Duration? get duration =>
      runTimeTicks != null ? Duration(microseconds: runTimeTicks! ~/ 10) : null;

  /// Returns a formatted label like "S01E05" for episodes, or null.
  String? get episodeLabel {
    if (parentIndexNumber != null && indexNumber != null) {
      return 'S${parentIndexNumber!.padLeft(2, '0')}E${indexNumber.toString().padLeft(2, '0')}';
    }
    return null;
  }

  /// Returns a display title including episode info if applicable.
  String get displayTitle {
    if (seriesName != null && episodeLabel != null) {
      return '$seriesName - $episodeLabel - $name';
    }
    if (episodeLabel != null) {
      return '$episodeLabel - $name';
    }
    return name;
  }
}

class JellyfinMediaSource {
  final String id;
  final String? path;
  final String? container;
  final int? bitrate;
  final bool? supportsDirectStream;
  final bool? supportsTranscoding;
  final String? type;

  JellyfinMediaSource({
    required this.id,
    this.path,
    this.container,
    this.bitrate,
    this.supportsDirectStream,
    this.supportsTranscoding,
    this.type,
  });

  factory JellyfinMediaSource.fromJson(Map<String, dynamic> json) {
    return JellyfinMediaSource(
      id: json['Id'] as String? ?? '',
      path: json['Path'] as String?,
      container: json['Container'] as String?,
      bitrate: json['Bitrate'] as int?,
      supportsDirectStream: json['SupportsDirectStream'] as bool?,
      supportsTranscoding: json['SupportsTranscoding'] as bool?,
      type: json['Type'] as String?,
    );
  }

  /// Whether this source is a valid video source.
  bool get isVideo => type == 'Default' || type == null;
}

class JellyfinMediaStream {
  final int index;
  final String? codec;
  final String? displayTitle;
  final String? language;
  final String? type; // "Video", "Audio", "Subtitle"
  final bool? isDefault;
  final bool? isExternal;
  final String? deliveryUrl;

  JellyfinMediaStream({
    required this.index,
    this.codec,
    this.displayTitle,
    this.language,
    this.type,
    this.isDefault,
    this.isExternal,
    this.deliveryUrl,
  });

  factory JellyfinMediaStream.fromJson(Map<String, dynamic> json) {
    return JellyfinMediaStream(
      index: json['Index'] as int? ?? 0,
      codec: json['Codec'] as String?,
      displayTitle: json['DisplayTitle'] as String?,
      language: json['Language'] as String?,
      type: json['Type'] as String?,
      isDefault: json['IsDefault'] as bool?,
      isExternal: json['IsExternal'] as bool?,
      deliveryUrl: json['DeliveryUrl'] as String?,
    );
  }

  /// Whether this stream is a subtitle track.
  bool get isSubtitle => type == 'Subtitle';

  /// Whether this stream is an audio track.
  bool get isAudio => type == 'Audio';

  /// Whether this stream is a video track.
  bool get isVideo => type == 'Video';

  /// A human-readable label for this stream.
  String get label {
    String base = displayTitle ?? language ?? 'Unknown';
    if (isDefault == true) {
      return '$base (Padrão)';
    }
    return base;
  }
}

class JellyfinDevice {
  final String id;
  final String name;
  final String? appName;
  final String? lastUserName;
  final DateTime? lastPlaybackDate;
  final String? iconUrl;

  JellyfinDevice({
    required this.id,
    required this.name,
    this.appName,
    this.lastUserName,
    this.lastPlaybackDate,
    this.iconUrl,
  });

  factory JellyfinDevice.fromJson(Map<String, dynamic> json) {
    return JellyfinDevice(
      id: json['Id'] as String? ?? '',
      name: json['Name'] as String? ?? 'Unknown',
      appName: json['AppName'] as String?,
      lastUserName: json['LastUserName'] as String?,
      lastPlaybackDate: json['DateLastActivity'] != null
          ? DateTime.tryParse(json['DateLastActivity'] as String)
          : null,
      iconUrl: json['IconUrl'] as String?,
    );
  }

  /// Whether this device is likely a Chromecast or TV device.
  bool get isCastDevice =>
      appName?.contains('Chromecast') == true ||
      appName?.contains('Android TV') == true ||
      appName?.contains('Google TV') == true ||
      name.toLowerCase().contains('tv') ||
      name.toLowerCase().contains('chromecast');
}

class JellyfinSession {
  final String id;
  final String deviceId;
  final String deviceName;
  final String? client;
  final bool isPaused;
  final int positionTicks;
  final String? nowPlayingItemId;
  final String? nowPlayingItemName;

  JellyfinSession({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    this.client,
    required this.isPaused,
    required this.positionTicks,
    this.nowPlayingItemId,
    this.nowPlayingItemName,
  });

  factory JellyfinSession.fromJson(Map<String, dynamic> json) {
    final playState = json['PlayState'] as Map<String, dynamic>?;
    final nowPlaying = json['NowPlayingItem'] as Map<String, dynamic>?;

    return JellyfinSession(
      id: json['Id'] as String? ?? '',
      deviceId: json['DeviceId'] as String? ?? '',
      deviceName: json['DeviceName'] as String? ?? '',
      client: json['Client'] as String?,
      isPaused: playState?['IsPaused'] as bool? ?? false,
      positionTicks: playState?['PositionTicks'] as int? ?? 0,
      nowPlayingItemId: nowPlaying?['Id'] as String?,
      nowPlayingItemName: nowPlaying?['Name'] as String?,
    );
  }

  /// Current playback position as a [Duration].
  Duration get position => Duration(microseconds: positionTicks ~/ 10);
}

class JellyfinAuthResult {
  final String accessToken;
  final String userId;
  final String serverId;

  JellyfinAuthResult({
    required this.accessToken,
    required this.userId,
    required this.serverId,
  });

  factory JellyfinAuthResult.fromJson(Map<String, dynamic> json) {
    final user = json['User'] as Map<String, dynamic>?;
    return JellyfinAuthResult(
      accessToken: json['AccessToken'] as String? ?? '',
      userId: user?['Id'] as String? ?? '',
      serverId: json['ServerId'] as String? ?? '',
    );
  }
}
