import 'package:dio/dio.dart';
import 'package:server_core/server_core.dart';

/// Jellyfin implementation of [UserViewsApi].
class JellyfinUserViewsApi implements UserViewsApi {
  final Dio _dio;
  String Function() _getUserId;

  JellyfinUserViewsApi(this._dio, this._getUserId);

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
  Future<MediaItem> getView(String viewId) async {
    final response = await _dio.get('/Users/$_userId/Views/$viewId');
    return MediaItem.fromJson(response.data as Map<String, dynamic>);
  }
}
