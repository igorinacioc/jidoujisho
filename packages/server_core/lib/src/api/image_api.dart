/// Image API contract — constructing image URLs.
abstract class ImageApi {
  /// Returns the URL for an item's image.
  ///
  /// [itemId] is the item to get the image for.
  /// [imageTag] is the image tag from [MediaItem.imageTags].
  /// [imageType] is the type of image (Primary, Backdrop, Logo, etc.).
  /// [quality] is the JPEG quality (1-100, default 90).
  String getImageUrl(
    String itemId,
    String imageTag, {
    String imageType,
    int? quality,
  });

  /// Returns the URL for a backdrop image.
  ///
  /// Convenience method that calls [getImageUrl] with imageType='Backdrop'.
  String getBackdropUrl(String itemId, String imageTag);

  /// Returns the URL for a logo image.
  String getLogoUrl(String itemId, String imageTag);

  /// Returns the URL for a thumbnail image.
  String getThumbnailUrl(String itemId, String imageTag);
}
