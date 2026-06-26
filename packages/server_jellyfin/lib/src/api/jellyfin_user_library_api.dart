import 'package:dio/dio.dart';
import 'package:server_core/server_core.dart';

/// Jellyfin implementation of [UserLibraryApi].
class JellyfinUserLibraryApi implements UserLibraryApi {
  final Dio _dio;
  String Function() _getUserId;

  JellyfinUserLibraryApi(this._dio, this._getUserId);

  String get _userId => _getUserId();

  @override
  Future<List<MediaItem>> getLatestItems({
    int? startIndex,
    int? limit,
    List<String>? includeItemTypes,
  }) async {
    final query = <String, dynamic>{
      'userId': _userId,
      'Fields': 'MediaSources,MediaStreams,Overview,RunTimeTicks,People',
      'Recursive': 'true',
    };
    if (startIndex != null) query['StartIndex'] = startIndex.toString();
    if (limit != null) query['Limit'] = limit.toString();
    if (includeItemTypes != null && includeItemTypes.isNotEmpty) {
      query['IncludeItemTypes'] = includeItemTypes.join(',');
    }

    final response = await _dio.get(
      '/Users/$_userId/Items/Latest',
      queryParameters: query,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getResumeItems({
    int? startIndex,
    int? limit,
  }) async {
    final query = <String, dynamic>{
      'userId': _userId,
      'Fields': 'MediaSources,MediaStreams,Overview,RunTimeTicks',
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
  Future<void> setFavorite(String itemId, bool isFavorite) async {
    await _dio.post('/Users/$_userId/FavoriteItems/$itemId', data: {
      'IsFavorite': isFavorite,
    });
  }

  @override
  Future<void> setPlayed(String itemId, bool isPlayed) async {
    if (isPlayed) {
      await _dio.post('/Users/$_userId/PlayedItems/$itemId');
    } else {
      await _dio.delete('/Users/$_userId/PlayedItems/$itemId');
    }
  }

  @override
  Future<List<MediaItem>> getFavorites({
    int? startIndex,
    int? limit,
  }) async {
    final query = <String, dynamic>{
      'userId': _userId,
      'Fields': 'MediaSources,MediaStreams,Overview,RunTimeTicks',
    };
    if (startIndex != null) query['StartIndex'] = startIndex.toString();
    if (limit != null) query['Limit'] = limit.toString();

    final response = await _dio.get(
      '/Users/$_userId/Items',
      queryParameters: {
        ...query,
        'Filters': 'IsFavorite',
        'Recursive': 'true',
      },
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
