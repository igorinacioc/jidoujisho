import 'package:flutter/material.dart';

/// A compact remote control bar for the mining mode.
///
/// Shows playback controls (play/pause, seek forward/backward)
/// and status information for the current cast session.
class MiningControls extends StatelessWidget {
  const MiningControls({
    required this.isPlaying,
    required this.currentPosition,
    this.totalDuration,
    this.onPlayPause,
    this.onSeekForward,
    this.onSeekBackward,
    this.onStop,
    this.onLoopToggle,
    this.isLooping = false,
    this.syncOffset = Duration.zero,
    this.onSyncAdjust,
    this.onSyncReset,
    Key? key,
  }) : super(key: key);

  /// Whether the remote session is currently playing.
  final bool isPlaying;

  /// Current playback position.
  final Duration currentPosition;

  /// Total duration of the media (optional).
  final Duration? totalDuration;

  /// Called when play/pause is pressed.
  final VoidCallback? onPlayPause;

  /// Called when seek forward (e.g. +10s) is pressed.
  final VoidCallback? onSeekForward;

  /// Called when seek backward (e.g. -10s) is pressed.
  final VoidCallback? onSeekBackward;

  /// Called when stop is pressed.
  final VoidCallback? onStop;

  /// Called to toggle loop/shadowing mode.
  final VoidCallback? onLoopToggle;

  /// Whether looping/shadowing mode is active.
  final bool isLooping;

  /// Current sync offset between TV and subtitles.
  final Duration syncOffset;

  /// Called with a delta to adjust the sync offset.
  final void Function(Duration delta)? onSyncAdjust;

  /// Called to reset the sync offset to zero.
  final VoidCallback? onSyncReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(bottom: 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            if (totalDuration != null) _buildProgressBar(),

            // Controls row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Stop
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Stop',
                    onPressed: onStop,
                    size: 22,
                  ),

                  // Seek backward
                  _buildControlButton(
                    icon: Icons.replay_10,
                    label: '-10s',
                    onPressed: onSeekBackward,
                  ),

                  // Play/Pause (larger)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: onPlayPause,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  // Seek forward
                  _buildControlButton(
                    icon: Icons.forward_10,
                    label: '+10s',
                    onPressed: onSeekForward,
                  ),

                  // Loop / Shadowing toggle
                  _buildControlButton(
                    icon: Icons.loop,
                    label: 'Loop',
                    onPressed: onLoopToggle,
                    isActive: isLooping,
                  ),
                ],
              ),
            ),

            // Sync calibration
            _buildSyncCalibration(),

            // Position text
            Text(
              _formatDuration(currentPosition),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a thin progress bar.
  Widget _buildProgressBar() {
    final progress =
        totalDuration!.inMilliseconds > 0
            ? currentPosition.inMilliseconds / totalDuration!.inMilliseconds
            : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(
            Colors.white54,
          ),
          minHeight: 3,
        ),
      ),
    );
  }

  /// Builds a single control button with label.
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    double size = 24,
    bool isActive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isActive ? Colors.blue : Colors.white,
            size: size,
          ),
          onPressed: onPressed,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// Builds the sync calibration row with +/- buttons and offset display.
  Widget _buildSyncCalibration() {
    final ms = syncOffset.inMilliseconds;
    final isAdjusted = ms != 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sync,
            size: 14,
            color: isAdjusted
                ? Colors.amber.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 6),

          // -100ms
          _buildSyncButton(
            icon: Icons.remove,
            onTap: () => onSyncAdjust?.call(const Duration(milliseconds: -100)),
          ),

          // Offset value
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isAdjusted
                  ? Colors.amber.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: Text(
              '${ms > 0 ? "+" : ""}$ms ms',
              style: TextStyle(
                color: isAdjusted
                    ? Colors.amber.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.3),
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight:
                    isAdjusted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),

          // +100ms
          _buildSyncButton(
            icon: Icons.add,
            onTap: () => onSyncAdjust?.call(const Duration(milliseconds: 100)),
          ),

          // Reset (only visible when adjusted)
          if (isAdjusted) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onSyncReset,
              child: Icon(
                Icons.restart_alt,
                size: 14,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a tiny +/- button for sync adjustment.
  Widget _buildSyncButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
        ),
        child: Icon(
          icon,
          size: 12,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Formats a duration as mm:ss.
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
