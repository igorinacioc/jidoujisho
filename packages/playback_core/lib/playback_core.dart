/// Playback core abstraction layer.
///
/// Provides pluggable interfaces for stream resolution and playback,
/// allowing different backends (media_kit, VLC, ExoPlayer) to be
/// swapped without changing business logic.
library;

export 'src/media_stream_resolver.dart';
export 'src/stream_resolution_result.dart';
