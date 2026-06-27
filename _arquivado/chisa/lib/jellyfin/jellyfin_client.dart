import 'dart:convert';

import 'package:http/http.dart' as http;

import 'jellyfin_models.dart';

/// REST client for the Jellyfin API.
///
/// Handles authentication, library browsing, streaming URLs,
/// subtitle retrieval, session management, and device discovery.
///
/// Usage:
/// ```dart
/// final client = JellyfinClient('http://192.168.1.100:8096');
/// await client.authenticate('username', 'password');
/// final views = await client.getViews();
/// ```
class JellyfinClient {
  final String serverUrl;

  String? _accessToken;
  String? _userId;
  final String _deviceId = 'jidoujisho-${DateTime.now().millisecondsSinceEpoch}';
  final String _clientName = 'jidoujisho';

  /// HTTP client for making requests.
  final http.Client _httpClient = http.Client();

  JellyfinClient(String url) : serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  // ─── Getters ───────────────────────────────────────────────────────────

  /// Whether the client is currently authenticated.
  bool get isAuthenticated => _accessToken != null && _userId != null;

  /// The current access token, if authenticated.
  String? get accessToken => _accessToken;

  /// The current user ID, if authenticated.
  String? get userId => _userId;

  // ─── Authentication ────────────────────────────────────────────────────

  /// Authenticates with the Jellyfin server.
  ///
  /// Returns an [JellyfinAuthResult] with the access token and user info.
  /// Throws [JellyfinException] on failure.
  Future<JellyfinAuthResult> authenticate(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$serverUrl/Users/Authenticate');

    final authHeader = _createAuthHeader(username, password);

    try {
      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
        body: jsonEncode({
          'Username': username,
          'Pw': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = JellyfinAuthResult.fromJson(data);
        _accessToken = result.accessToken;
        _userId = result.userId;
        return result;
      } else if (response.statusCode == 401) {
        throw JellyfinException('Invalid username or password.');
      } else {
        throw JellyfinException(
          'Authentication failed: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is JellyfinException) rethrow;
      throw JellyfinException('Could not connect to Jellyfin server: $e');
    }
  }

  /// Sets credentials directly (e.g. from saved settings).
  void setCredentials({
    required String accessToken,
    required String userId,
  }) {
    _accessToken = accessToken;
    _userId = userId;
  }

  /// Logs out and clears credentials.
  void logout() {
    _accessToken = null;
    _userId = null;
  }

  // ─── Library Browsing ──────────────────────────────────────────────────

  /// Gets the list of user views (libraries).
  Future<List<JellyfinItem>> getViews() async {
    _ensureAuthenticated();
    final url = Uri.parse('$serverUrl/Users/$_userId/Views');

    final response = await _get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['Items'] as List<dynamic>? ?? [];

    return items
        .map((e) => JellyfinItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Gets items from a specific library or folder.
  ///
  /// [parentId] is the folder/library ID to browse.
  /// [sortBy] determines the sort order (default: 'SortName').
  /// [recursive] whether to fetch items recursively.
  /// [includeItemTypes] filters by item types (e.g. ['Movie', 'Episode']).
  Future<List<JellyfinItem>> getItems(
    String parentId, {
    String sortBy = 'SortName',
    bool recursive = true,
    List<String>? includeItemTypes,
    int? startIndex,
    int? limit,
  }) async {
    _ensureAuthenticated();

    final queryParams = <String, String>{
      'ParentId': parentId,
      'SortBy': sortBy,
      'SortOrder': 'Ascending',
      'Recursive': recursive.toString(),
      'Fields': 'MediaSources,MediaStreams,Overview,RunTimeTicks',
      'IncludeItemTypes': (includeItemTypes ?? ['Movie', 'Episode']).join(','),
    };

    if (startIndex != null) {
      queryParams['StartIndex'] = startIndex.toString();
    }
    if (limit != null) {
      queryParams['Limit'] = limit.toString();
    }

    final url = Uri.parse('$serverUrl/Users/$_userId/Items')
        .replace(queryParameters: queryParams);

    final response = await _get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['Items'] as List<dynamic>? ?? [];

    return items
        .map((e) => JellyfinItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Gets detailed info about a specific item.
  Future<JellyfinItem> getItem(String itemId) async {
    _ensureAuthenticated();

    final url = Uri.parse('$serverUrl/Users/$_userId/Items/$itemId')
        .replace(queryParameters: {
      'Fields': 'MediaSources,MediaStreams,Overview,RunTimeTicks,People',
    });

    final response = await _get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return JellyfinItem.fromJson(data);
  }

  // ─── Streaming URLs ────────────────────────────────────────────────────

  /// Returns the direct stream URL for a media item.
  ///
  /// [itemId] is the item to stream.
  /// [mediaSourceId] is the specific media source (use id from [JellyfinMediaSource]).
  /// [deviceId] is a unique identifier for this device.
  String getStreamUrl(
    String itemId,
    String mediaSourceId, [
    String? deviceId,
  ]) {
    final effectiveDeviceId = deviceId ?? _deviceId;
    return '$serverUrl/Videos/$itemId/stream'
        '?Static=true'
        '&MediaSourceId=$mediaSourceId'
        '&DeviceId=$effectiveDeviceId'
        '&ApiKey=$_accessToken';
  }

  /// Returns the direct stream URL for audio only.
  String getAudioStreamUrl(
    String itemId,
    String mediaSourceId, [
    String? deviceId,
  ]) {
    final effectiveDeviceId = deviceId ?? _deviceId;
    return '$serverUrl/Videos/$itemId/stream'
        '?Static=true'
        '&MediaSourceId=$mediaSourceId'
        '&DeviceId=$effectiveDeviceId'
        '&ApiKey=$_accessToken'
        '&audioCodec=aac';
  }

  // ─── Subtitles ─────────────────────────────────────────────────────────

  /// Gets the raw subtitle content for a given media item.
  ///
  /// [itemId] is the media item.
  /// [mediaSourceId] is the media source that has the subtitle.
  /// [subtitleIndex] is the index of the subtitle stream (from [JellyfinMediaStream.index]).
  /// Returns the raw subtitle text (SRT or ASS format).
  Future<String> getSubtitleContent(
    String itemId,
    String mediaSourceId,
    int subtitleIndex,
  ) async {
    _ensureAuthenticated();

    final url = Uri.parse(
      '$serverUrl/Videos/$itemId/$mediaSourceId/Subtitles/$subtitleIndex/Stream',
    );

    final response = await _get(url);
    return response.body;
  }

  /// Gets a list of available subtitle streams for an item.
  ///
  /// Convenience method that calls [getItem] and filters for subtitle streams.
  Future<List<JellyfinMediaStream>> getSubtitleStreams(String itemId) async {
    final item = await getItem(itemId);
    return item.mediaStreams
            ?.where((s) => s.isSubtitle)
            .toList() ??
        [];
  }

  /// Downloads and parses a subtitle file from Jellyfin.
  ///
  /// Returns the raw content string. Use [SubtitleUtils] to parse it.
  Future<String> downloadSubtitles(
    String itemId,
    String mediaSourceId,
    int subtitleIndex,
  ) async {
    return getSubtitleContent(itemId, mediaSourceId, subtitleIndex);
  }

  // ─── Session / Playback Control ────────────────────────────────────────

  /// Starts playback of a media item on a specific device.
  ///
  /// [itemId] is the media to play.
  /// [mediaSourceId] is the media source to use.
  /// [deviceId] is the Chromecast/TV device to cast to.
  /// Returns the session ID.
  Future<String> startPlayback(
    String itemId,
    String mediaSourceId,
    String deviceId,
  ) async {
    _ensureAuthenticated();

    final url = Uri.parse('$serverUrl/Sessions/Playing');

    final body = jsonEncode({
      'ItemId': itemId,
      'PlayMethod': 'Transcode',
      'CanSeek': true,
      'MediaSourceId': mediaSourceId,
      'DeviceId': deviceId,
    });

    final response = await _post(url, body: body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Get session to find the session ID.
      final session = await getSession(deviceId);
      return session?.id ?? '';
    }

    throw JellyfinException(
      'Failed to start playback: ${response.statusCode}',
    );
  }

  /// Gets the current session for a device.
  Future<JellyfinSession?> getSession(String deviceId) async {
    _ensureAuthenticated();

    final url = Uri.parse('$serverUrl/Sessions')
        .replace(queryParameters: {'DeviceId': deviceId});

    final response = await _get(url);
    final List<dynamic> sessions = jsonDecode(response.body) as List<dynamic>;

    if (sessions.isEmpty) return null;

    return JellyfinSession.fromJson(sessions.first as Map<String, dynamic>);
  }

  /// Sends a playback command to a session.
  ///
  /// Commands: PlayPause, Stop, Seek
  /// For Seek, provide [seekTicks] (1 tick = 100ns).
  Future<void> sendCommand(
    String sessionId,
    String command, {
    int? seekTicks,
  }) async {
    _ensureAuthenticated();

    final url = Uri.parse('$serverUrl/Sessions/$sessionId/Playing/$command');

    final body = seekTicks != null
        ? jsonEncode({'SeekPositionTicks': seekTicks})
        : null;

    final response = body != null
        ? await _post(url, body: body)
        : await _post(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw JellyfinException(
        'Command "$command" failed: ${response.statusCode}',
      );
    }
  }

  /// Pauses playback on a session.
  Future<void> playPause(String sessionId) => sendCommand(sessionId, 'PlayPause');

  /// Stops playback on a session.
  Future<void> stop(String sessionId) => sendCommand(sessionId, 'Stop');

  /// Seeks to a specific position in a session.
  Future<void> seek(String sessionId, Duration position) =>
      sendCommand(sessionId, 'Seek', seekTicks: position.inMicroseconds * 10);

  // ─── Devices ───────────────────────────────────────────────────────────

  /// Gets the list of available devices on the server.
  Future<List<JellyfinDevice>> getDevices() async {
    _ensureAuthenticated();

    final url = Uri.parse('$serverUrl/Devices');

    final response = await _get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['Items'] as List<dynamic>? ?? [];

    return items
        .map((e) => JellyfinDevice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Discovers Chromecast-compatible devices on the network via Jellyfin.
  Future<List<JellyfinDevice>> discoverCastDevices() async {
    final devices = await getDevices();
    return devices.where((d) => d.isCastDevice).toList();
  }

  // ─── Image URLs ────────────────────────────────────────────────────────

  /// Returns the URL for an item's primary image.
  ///
  /// [itemId] is the item to get the image for.
  /// [imageTag] is the image tag (from [JellyfinItem.imageTags]).
  /// [imageType] is the type of image (default: 'Primary').
  String getImageUrl(
    String itemId,
    String imageTag, {
    String imageType = 'Primary',
  }) {
    return '$serverUrl/Items/$itemId/Images/$imageType'
        '?tag=$imageTag'
        '&quality=90';
  }

  /// Returns the URL for a backdrop image.
  String getBackdropUrl(String itemId, String imageTag) {
    return getImageUrl(itemId, imageTag, imageType: 'Backdrop');
  }

  // ─── Internal Helpers ──────────────────────────────────────────────────

  /// Ensures the client is authenticated before making requests.
  void _ensureAuthenticated() {
    if (!isAuthenticated) {
      throw JellyfinException('Not authenticated. Call authenticate() first.');
    }
  }

  /// Creates the authorization header following the Jellyfin/Emby format.
  String _createAuthHeader(String username, String password) {
    return 'MediaBrowser '
        'Client="$_clientName", '
        'Device="Android", '
        'DeviceId="$_deviceId", '
        'Version="1.0.0"';
  }

  /// Performs an authenticated GET request.
  Future<http.Response> _get(Uri url) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['X-Emby-Authorization'] = _createEmbyAuthHeader();
    }

    final response = await _httpClient.get(url, headers: headers);

    if (response.statusCode >= 400) {
      throw JellyfinException(
        'Request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    return response;
  }

  /// Performs an authenticated POST request.
  Future<http.Response> _post(Uri url, {String? body}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['X-Emby-Authorization'] = _createEmbyAuthHeader();
    }

    final response = await _httpClient.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode >= 400) {
      throw JellyfinException(
        'Request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    return response;
  }

  /// Creates the X-Emby-Authorization header for authenticated requests.
  String _createEmbyAuthHeader() {
    return 'MediaBrowser '
        'Client="$_clientName", '
        'Device="Android", '
        'DeviceId="$_deviceId", '
        'Version="1.0.0", '
        'Token="$_accessToken"';
  }

  /// Disposes of the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}

/// Exception thrown when a Jellyfin API request fails.
class JellyfinException implements Exception {
  final String message;

  JellyfinException(this.message);

  @override
  String toString() => 'JellyfinException: $message';
}
