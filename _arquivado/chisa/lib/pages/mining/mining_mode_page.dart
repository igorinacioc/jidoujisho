import 'package:chisa/jellyfin/cast_session_manager.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/subtitle_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';

import 'mining_controls.dart';
import 'mining_subtitle_display.dart';

/// The dedicated mining-mode screen that shows interactive subtitles
/// while the video plays on a cast device (TV).
///
/// The user can tap words to look them up in the dictionary,
/// long-press for flashcard creation, and control playback remotely.
class MiningModePage extends StatefulWidget {
  const MiningModePage({
    required this.castSession,
    required this.subtitles,
    required this.onExitMining,
    Key? key,
  }) : super(key: key);

  /// The cast session manager for position polling and remote control.
  final CastSessionManager castSession;

  /// The list of subtitle items available for this media.
  final List<SubtitleItem> subtitles;

  /// Called when the user wants to exit mining mode.
  final VoidCallback onExitMining;

  @override
  State<MiningModePage> createState() => _MiningModePageState();
}

class _MiningModePageState extends State<MiningModePage> {
  Subtitle? _currentSubtitle;
  int _currentIndex = -1;
  bool _isLooping = false;

  @override
  void initState() {
    super.initState();
    widget.castSession.addListener(_onSessionUpdate);
    widget.castSession.startPolling();
  }

  @override
  void dispose() {
    widget.castSession.removeListener(_onSessionUpdate);
    super.dispose();
  }

  /// Called whenever the cast session updates (new position, play/pause, etc).
  void _onSessionUpdate() {
    if (!mounted) return;
    _updateCurrentSubtitle();
  }

  /// Finds the subtitle that corresponds to the current remote position.
  void _updateCurrentSubtitle() {
    final pos = widget.castSession.syncedPosition;

    int? bestMatch; // All subtitles.

    for (int i = 0; i < widget.subtitles.length; i++) {
      final controller = widget.subtitles[i].controller;
      final subs = controller.subtitles;

      final newIndex = subs.indexWhere(
        (s) => s.start <= pos && s.end >= pos,
      );

      if (newIndex != -1) {
        bestMatch = i;
        break;
      }
    }

    if (bestMatch == null) {
      // No matching subtitle — no active subtitle for this position.
      return;
    }

    final controller = widget.subtitles[bestMatch].controller;
    final subs = controller.subtitles;
    final newIndex = subs.indexWhere(
      (s) => s.start <= pos && s.end >= pos,
    );

    if (newIndex != -1 && newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
        _currentSubtitle = subs[newIndex];
      });

      // If looping is enabled, seek back to start of this subtitle.
      if (_isLooping && _currentSubtitle != null) {
        final endPos = _currentSubtitle!.end;
        if (pos >= endPos) {
          widget.castSession.seek(_currentSubtitle!.start);
        }
      }
    }
  }

  /// Handles a word tap — opens dictionary lookup.
  Future<void> _onWordTap(String word) async {
    final appModel = Provider.of<AppModel>(context, listen: false);

    try {
      final result = await appModel.searchDictionary(word.trim());
      if (!mounted) return;

      _showDictionaryPopup(result);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not look up "$word"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Shows a dictionary search result in a bottom sheet.
  void _showDictionaryPopup(result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scrollController) {
            final entries = result.entries as List? ?? [];

            if (entries.isEmpty) {
              return Center(
                child: Text(
                  'No results found',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              );
            }

            return ListView.builder(
              controller: scrollController,
              itemCount: entries.length,
              itemBuilder: (ctx, i) {
                final entry = entries[i];
                return _buildDictionaryEntry(ctx, entry);
              },
            );
          },
        );
      },
    );
  }

  /// Builds a single dictionary entry in the popup.
  Widget _buildDictionaryEntry(BuildContext context, dynamic entry) {
    // Adapt based on the entry type from the dictionary system.
    // Most entries have term, reading, and definitions.
    final String term = entry.term?.toString() ?? '';
    final String reading = entry.reading?.toString() ?? '';
    final List<dynamic> definitions =
        entry.definitions as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term + reading
          Row(
            children: [
              Text(
                term.isNotEmpty ? term : '(unknown)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (reading.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  reading,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Definitions
          if (definitions.isNotEmpty)
            ...definitions.map((def) {
              final String defText = def is Map
                  ? (def['definition']?.toString() ?? def.toString())
                  : def.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  defText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subs = _currentSubtitle != null
        ? widget.subtitles.isNotEmpty
            ? widget.subtitles.first.controller.subtitles
            : null
        : null;

    final previousSub = _currentIndex > 0 && subs != null
        ? subs[_currentIndex - 1]
        : null;

    final nextSub = _currentIndex < (subs?.length ?? 1) - 1 && subs != null
        ? subs[_currentIndex + 1]
        : null;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.onExitMining();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Header bar
              _buildHeader(context),

              // Subtitle display (main content)
              Expanded(
                child: MiningSubtitleDisplay(
                  currentSubtitle: _currentSubtitle,
                  previousSubtitle: previousSub,
                  nextSubtitle: nextSub,
                  onWordTap: _onWordTap,
                ),
              ),

              // Remote controls (bottom)
              MiningControls(
                isPlaying: widget.castSession.isPlaying,
                currentPosition: widget.castSession.syncedPosition,
                onPlayPause: () => widget.castSession.playPause(),
                onSeekForward: () =>
                    widget.castSession.seekForward(const Duration(seconds: 10)),
                onSeekBackward: () => widget.castSession
                    .seekBackward(const Duration(seconds: 10)),
                onStop: () => widget.onExitMining(),
                onLoopToggle: () =>
                    setState(() => _isLooping = !_isLooping),
                isLooping: _isLooping,
                syncOffset: widget.castSession.syncOffset,
                onSyncAdjust: (delta) =>
                    widget.castSession.adjustSyncOffset(delta),
                onSyncReset: () => widget.castSession.resetSyncOffset(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a minimal top bar with exit button and session indicator.
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.black,
      child: Row(
        children: [
          // Exit button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white54),
            onPressed: widget.onExitMining,
            tooltip: 'Exit Mining Mode',
          ),
          const SizedBox(width: 4),
          // Session status
          Icon(
            widget.castSession.isActive ? Icons.cast_connected : Icons.cast,
            color: widget.castSession.isActive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            widget.castSession.isActive ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          // Subtitle info
          if (_currentIndex >= 0)
            Text(
              '#${_currentIndex + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
