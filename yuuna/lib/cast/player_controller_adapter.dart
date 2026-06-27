import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// A universal player controller that wraps either VLC or media_kit.
///
/// Provides a common API for play/pause/seek/position/track-selection so
/// the UI doesn't need to know which backend is active.
class UniversalPlayerController extends ChangeNotifier {
  // ─── VLC backend ─────────────────────────────────────────────────────────

  VlcPlayerController? _vlc;

  // ─── media_kit backend ───────────────────────────────────────────────────

  Player? _mkPlayer;
  VideoController? _mkVideo;
  StreamSubscription? _mkPositionSub;
  StreamSubscription? _mkStateSub;
  StreamSubscription? _mkDurationSub;
  StreamSubscription? _mkCompletedSub;

  // ─── Common state ────────────────────────────────────────────────────────

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isEnded = false;
  bool _isInitialized = false;
  double _aspectRatio = 16 / 9;

  /// Whether the player is currently playing.
  bool get isPlaying => _isPlaying;

  /// Current playback position.
  Duration get position => _position;

  /// Total media duration.
  Duration get duration => _duration;

  /// Whether playback has ended.
  bool get isEnded => _isEnded;

  /// Whether the player has been initialized.
  bool get isInitialized => _isInitialized;

  /// Video aspect ratio (width / height).
  double get aspectRatio => _aspectRatio;

  /// Returns the underlying backend type.
  String get backendType => _vlc != null ? 'vlc' : 'media_kit';

  /// The raw VLC controller (null if using media_kit).
  VlcPlayerController? get vlcController => _vlc;

  /// The raw media_kit Player (null if using VLC).
  Player? get mkPlayer => _mkPlayer;

  /// The raw media_kit VideoController (null if using VLC).
  VideoController? get mkVideo => _mkVideo;

  /// The current media URL (for quality comparison).
  String? get dataSource {
    if (_vlc != null) {
      return _vlc!.dataSource;
    }
    return null;
  }

  // ─── Factory: VLC ────────────────────────────────────────────────────────

  /// Creates a wrapper around a [VlcPlayerController].
  factory UniversalPlayerController.vlc(VlcPlayerController controller) {
    final wrapper = UniversalPlayerController._();
    wrapper._vlc = controller;
    controller.addListener(wrapper._onVlcUpdate);
    wrapper._syncFromVlc();
    return wrapper;
  }

  // ─── Factory: media_kit ──────────────────────────────────────────────────

  /// Creates a wrapper around a media_kit [Player] + [VideoController].
  factory UniversalPlayerController.mediaKit({
    required Player player,
    required VideoController videoController,
    Duration startPosition = Duration.zero,
  }) {
    final wrapper = UniversalPlayerController._();
    wrapper._mkPlayer = player;
    wrapper._mkVideo = videoController;

    // Track whether we've received real position data from the engine.
    // Used to avoid trusting premature "playing = false" events before
    // the media pipeline is fully initialized.
    bool engineConfirmed = false;

    // Position stream.
    wrapper._mkPositionSub = player.stream.position.listen((pos) {
      wrapper._position = pos;
      wrapper._isInitialized = true;
      if (!engineConfirmed && pos > Duration.zero) {
        engineConfirmed = true;
      }
      wrapper.notifyListeners();
    });

    // Playing state — only trust after engine has confirmed playback.
    wrapper._mkStateSub = player.stream.playing.listen((playing) {
      if (engineConfirmed || playing) {
        wrapper._isPlaying = playing;
      }
      wrapper._isEnded = false;
      wrapper.notifyListeners();
    });

    // Duration stream.
    wrapper._mkDurationSub = player.stream.duration.listen((dur) {
      wrapper._duration = dur;
      if (!engineConfirmed && dur > Duration.zero) {
        engineConfirmed = true;
        wrapper._isPlaying = true;
      }
      wrapper.notifyListeners();
    });

    // Completed stream — only trust if engine confirmed playback first.
    // On some platforms (emulator), media_kit may fire completed immediately
    // if the codec is unsupported. We guard against false positives.
    wrapper._mkCompletedSub = player.stream.completed.listen((_) {
      if (engineConfirmed) {
        wrapper._isEnded = true;
        wrapper._isPlaying = false;
        engineConfirmed = false;
      }
      wrapper.notifyListeners();
    });

    // Initial state. Default _isPlaying to true since the player was opened
    // with play:true. The engine may emit false before the pipeline starts.
    wrapper._isPlaying = true;
    wrapper._duration = player.state.duration;
    wrapper._position = player.state.position;

    // Seek to start if needed.
    if (startPosition > Duration.zero) {
      player.seek(startPosition);
    }

    // Mark as initialized.
    wrapper._isInitialized = true;

    return wrapper;
  }

  UniversalPlayerController._();

  // ─── VLC sync ────────────────────────────────────────────────────────────

  void _onVlcUpdate() {
    _syncFromVlc();
    notifyListeners();
  }

  void _syncFromVlc() {
    if (_vlc == null) return;
    _isInitialized = _vlc!.value.isInitialized;
    _isPlaying = _vlc!.value.isPlaying;
    _position = _vlc!.value.position;
    _duration = _vlc!.value.duration;
    _isEnded = _vlc!.value.isEnded;
    _aspectRatio = _vlc!.value.aspectRatio;
  }

  // ─── Playback API ────────────────────────────────────────────────────────

  /// Play or resume.
  Future<void> play() async {
    if (_vlc != null) {
      await _vlc!.play();
    } else if (_mkPlayer != null) {
      await _mkPlayer!.play();
    }
  }

  /// Pause playback.
  Future<void> pause() async {
    if (_vlc != null) {
      await _vlc!.pause();
    } else if (_mkPlayer != null) {
      await _mkPlayer!.pause();
    }
  }

  /// Toggle play/pause.
  Future<void> playOrPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Seek to a specific position.
  Future<void> seek(Duration position) async {
    if (_vlc != null) {
      await _vlc!.setTime(position.inMilliseconds);
    } else if (_mkPlayer != null) {
      await _mkPlayer!.seek(position);
    }
    _position = position;
  }

  /// Seek in milliseconds (VLC-compatible).
  Future<void> setTime(int milliseconds) async {
    await seek(Duration(milliseconds: milliseconds));
  }

  /// Seek relative to current position.
  Future<void> seekTo(Duration target) async {
    await seek(target);
  }

  /// Stop playback.
  Future<void> stop() async {
    if (_vlc != null) {
      await _vlc!.stop();
    } else if (_mkPlayer != null) {
      await _mkPlayer!.stop();
    }
    _isPlaying = false;
    _isEnded = false;
  }

  /// Set playback speed.
  void setPlaybackSpeed(double speed) {
    if (_vlc != null) {
      _vlc!.setPlaybackSpeed(speed);
    } else if (_mkPlayer != null) {
      _mkPlayer!.setRate(speed);
    }
  }

  // ─── Audio Track API ─────────────────────────────────────────────────────

  /// Returns a map of audio track index → label.
  Future<Map<int, String>> getAudioTracks() async {
    if (_vlc != null) {
      return await _vlc!.getAudioTracks();
    }
    if (_mkPlayer != null) {
      final tracks = _mkPlayer!.state.tracks.audio;
      final result = <int, String>{};
      for (int i = 0; i < tracks.length; i++) {
        final t = tracks[i];
        final lang = t.language ?? '';
        final title = t.title ?? 'Track ${i + 1}';
        result[i] = lang.isNotEmpty ? '$title ($lang)' : title;
      }
      return result;
    }
    return {};
  }

  /// Returns the currently active audio track index, or null.
  Future<int?> getAudioTrack() async {
    if (_vlc != null) {
      return await _vlc!.getAudioTrack();
    }
    if (_mkPlayer != null) {
      final tracks = _mkPlayer!.state.tracks.audio;
      // media_kit doesn't have a direct "current audio track" getter via index.
      // Return the first active track we can find.
      for (int i = 0; i < tracks.length; i++) {
        if (tracks[i].id == _mkPlayer!.state.tracks.audio.first.id) {
          return i;
        }
      }
    }
    return null;
  }

  /// Sets the active audio track by index.
  Future<void> setAudioTrack(int index) async {
    if (_vlc != null) {
      await _vlc!.setAudioTrack(index);
    }
    if (_mkPlayer != null) {
      final tracks = _mkPlayer!.state.tracks.audio;
      if (index < tracks.length) {
        await _mkPlayer!.setAudioTrack(tracks[index]);
      }
    }
  }

  // ─── Subtitle Track API ──────────────────────────────────────────────────

  /// Returns a map of SPU (subtitle) track index → label.
  Future<Map<int, String>> getSpuTracks() async {
    if (_vlc != null) {
      return await _vlc!.getSpuTracks();
    }
    if (_mkPlayer != null) {
      final tracks = _mkPlayer!.state.tracks.subtitle;
      final result = <int, String>{};
      for (int i = 0; i < tracks.length; i++) {
        final t = tracks[i];
        final lang = t.language ?? '';
        final title = t.title ?? 'Subtitle ${i + 1}';
        result[i] = lang.isNotEmpty ? '$title ($lang)' : title;
      }
      return result;
    }
    return {};
  }

  /// Returns the number of embedded subtitle tracks.
  Future<int> getSpuTracksCount() async {
    if (_vlc != null) {
      return await _vlc!.getSpuTracksCount() ?? 0;
    }
    if (_mkPlayer != null) {
      return _mkPlayer!.state.tracks.subtitle.length;
    }
    return 0;
  }

  /// Sets the active SPU (subtitle) track by index.
  Future<void> setSpuTrack(int index) async {
    if (_vlc != null) {
      await _vlc!.setSpuTrack(index);
    }
    if (_mkPlayer != null) {
      final tracks = _mkPlayer!.state.tracks.subtitle;
      if (index < tracks.length) {
        await _mkPlayer!.setSubtitleTrack(tracks[index]);
      }
    }
  }

  // ─── VLC-specific compatibility ──────────────────────────────────────────

  /// Registers a listener callback (VLC-compatible).
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  /// Removes a previously registered listener (VLC-compatible).
  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }

  /// Registers a callback to be invoked when the player is initialized.
  /// For already-initialized players, the callback fires immediately.
  void addOnInitListener(VoidCallback callback) {
    if (isInitialized) {
      callback();
    } else {
      addListener(() {
        if (isInitialized) {
          callback();
        }
      });
    }
  }

  /// Returns the total number of audio tracks.
  Future<int> getAudioTracksCount() async {
    final tracks = await getAudioTracks();
    return tracks.length;
  }

  /// No-op — VLC compat. Initialization is handled by the factory.
  Future<void> initialize() async {}

  // ─── Cleanup ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _mkPositionSub?.cancel();
    _mkStateSub?.cancel();
    _mkDurationSub?.cancel();
    _mkCompletedSub?.cancel();
    _mkPlayer?.dispose();
    _vlc?.dispose();
    super.dispose();
  }
}
