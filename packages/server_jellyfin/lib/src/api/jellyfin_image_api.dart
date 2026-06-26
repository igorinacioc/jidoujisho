import 'package:server_core/server_core.dart';

/// Jellyfin implementation of [ImageApi].
class JellyfinImageApi implements ImageApi {
  final String _baseUrl;

  JellyfinImageApi(this._baseUrl);

  @override
  String getImageUrl(
    String itemId,
    String imageTag, {
    String imageType = 'Primary',
    int? quality,
  }) {
    final q = quality ?? 90;
    return '$_baseUrl/Items/$itemId/Images/$imageType?tag=$imageTag&quality=$q';
  }

  @override
  String getBackdropUrl(String itemId, String imageTag) =>
      getImageUrl(itemId, imageTag, imageType: 'Backdrop');

  @override
  String getLogoUrl(String itemId, String imageTag) =>
      getImageUrl(itemId, imageTag, imageType: 'Logo');

  @override
  String getThumbnailUrl(String itemId, String imageTag) =>
      getImageUrl(itemId, imageTag, imageType: 'Thumbnail');
}
