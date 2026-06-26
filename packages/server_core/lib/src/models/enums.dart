/// Core enums used across the server API abstraction layer.
library;

/// The type of media item.
enum ItemType {
  movie,
  series,
  season,
  episode,
  folder,
  collection,
  playlist,
  audio,
  audiobook,
  book,
  photo,
  video,
  person,
  studio,
  genre,
  unknown,
}

/// Sort order for item queries.
enum SortOrder {
  ascending,
  descending,
}

/// Type of image to request from the server.
enum ImageType {
  primary,
  backdrop,
  logo,
  thumbnail,
  banner,
  screenshot,
}

/// The type of a media stream (track).
enum MediaStreamType {
  video,
  audio,
  subtitle,
  embeddedImage,
}

/// Playback method used by a session.
enum PlayMethod {
  directPlay,
  directStream,
  transcode,
}
