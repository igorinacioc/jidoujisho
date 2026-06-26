import 'package:dio/dio.dart';
import 'package:server_core/server_core.dart';

/// Jellyfin implementation of [ItemsApi].
class JellyfinItemsApi implements ItemsApi {
  final Dio _dio;
  String Function() _getUserId;

  JellyfinItemsApi(this._dio, this._getUserId);

  String get _userId => _getUserId();

  @override
  Future<List<MediaItem>> getViews() async {
    final response = await _dio.get('/Users/$_userId/Views');
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getItems(
    String parentId, {
    String sortBy = 'SortName',
    String sortOrder = 'Ascending',
    bool recursive = true,
    List<String>? includeItemTypes,
    int? startIndex,
    int? limit,
  }) async {
    final query = <String, dynamic>{
      'ParentId': parentId,
      'SortBy': sortBy,
      'SortOrder': sortOrder,
      'Recursive': recursive.toString(),
      'Fields': 'MediaSources,MediaStreams,Overview,RunTimeTicks,People,ImageTags,PrimaryImageAspectRatio',
    };

    if (includeItemTypes != null && includeItemTypes.isNotEmpty) {
      query['IncludeItemTypes'] = includeItemTypes.join(',');
    }
    if (startIndex != null) {
      query['StartIndex'] = startIndex.toString();
    }
    if (limit != null) {
      query['Limit'] = limit.toString();
    }

    final response = await _dio.get(
      '/Users/$_userId/Items',
      queryParameters: query,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MediaItem> getItem(String itemId) async {
    final response = await _dio.get(
      '/Users/$_userId/Items/$itemId',
      queryParameters: {
        'Fields': 'MediaSources,MediaStreams,Overview,RunTimeTicks,People,ImageTags,PrimaryImageAspectRatio',
      },
    );
    return MediaItem.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<MediaItem>> searchItems(
    String query, {
    List<String>? includeItemTypes,
    int? startIndex,
    int? limit,
  }) async {
    final params = <String, dynamic>{
      'SearchTerm': query,
      'Recursive': 'true',
      'IncludeMedia': 'true',
      'IncludePeople': 'false',
    };

    if (includeItemTypes != null && includeItemTypes.isNotEmpty) {
      params['IncludeItemTypes'] = includeItemTypes.join(',');
    }
    if (startIndex != null) {
      params['StartIndex'] = startIndex.toString();
    }
    if (limit != null) {
      params['Limit'] = limit.toString();
    }

    final response = await _dio.get(
      '/Users/$_userId/Items',
      queryParameters: params,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getNextUp({int? startIndex, int? limit}) async {
    final query = <String, dynamic>{
      'Fields': 'MediaSources,MediaStreams,Overview',
    };
    if (startIndex != null) query['StartIndex'] = startIndex.toString();
    if (limit != null) query['Limit'] = limit.toString();

    final response = await _dio.get(
      '/Shows/NextUp',
      queryParameters: query,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getResumeItems({int? startIndex, int? limit}) async {
    final query = <String, dynamic>{
      'Fields': 'MediaSources,MediaStreams,Overview',
      'Recursive': 'true',
    };
    if (startIndex != null) query['StartIndex'] = startIndex.toString();
    if (limit != null) query['Limit'] = limit.toString();

    final response = await _dio.get(
      '/Users/$_userId/Items/Resume',
      queryParameters: query,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getSeasons(String seriesId) async {
    final response = await _dio.get(
      '/Shows/$seriesId/Seasons',
      queryParameters: {
        'userId': _userId,
        'Fields': 'Overview',
      },
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getEpisodes(
    String seriesId,
    String seasonId, {
    int? startIndex,
    int? limit,
  }) async {
    final query = <String, dynamic>{
      'seasonId': seasonId,
      'userId': _userId,
      'Fields': 'MediaSources,MediaStreams,Overview',
    };
    if (startIndex != null) query['StartIndex'] = startIndex.toString();
    if (limit != null) query['Limit'] = limit.toString();

    final response = await _dio.get(
      '/Shows/$seriesId/Episodes',
      queryParameters: query,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
