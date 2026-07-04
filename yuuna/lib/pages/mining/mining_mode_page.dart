import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/cast/cast.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages/mining/mining_controls.dart';
import 'package:yuuna/pages/mining/mining_subtitle_display.dart';
import 'package:yuuna/utils.dart';

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
    required this.appModel,
    super.key,
  });

  /// The cast session for position polling and remote control.
  /// Can be [CastController] (Jellyfin) or [DlnaController] (DLNA/UPnP).
  final CastSession castSession;

  /// The list of subtitle items available for this media.
  final List<SubtitleItem> subtitles;

  /// Called when the user wants to exit mining mode.
  final VoidCallback onExitMining;

  /// The application model for dictionary lookup.
  final AppModel appModel;

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
    debugPrint('[MiningMode] Init: ${widget.subtitles.length} subtitle files, '
        'total cues=${widget.subtitles.fold<int>(0, (sum, s) => sum + s.controller.subtitles.length)}');
    for (int i = 0; i < widget.subtitles.length; i++) {
      final s = widget.subtitles[i];
      debugPrint('[MiningMode] Subtitle $i: "${s.metadata}" '
          'cues=${s.controller.subtitles.length} '
          'initialized=${s.controller.initialized}');
    }
    widget.castSession.addListener(_onSessionUpdate);
    widget.castSession.startPolling();
    debugPrint('[MiningMode] Started polling, session active=${widget.castSession.isActive}');
  }

  @override
  void dispose() {
    debugPrint('[MiningMode] Disposing, stopping polling');
    widget.castSession.removeListener(_onSessionUpdate);
    super.dispose();
  }

  /// Called whenever the cast session updates (new position, play/pause, etc).
  void _onSessionUpdate() {
    if (!mounted) return;
    _updateCurrentSubtitle();
  }

  bool _firstSubtitleLogged = false;

  /// Finds the subtitle that corresponds to the current remote position.
  void _updateCurrentSubtitle() {
    final pos = widget.castSession.syncedPosition;

    int? bestMatch;

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
      if (!_firstSubtitleLogged || pos.inSeconds % 5 == 0) {
        debugPrint('[MiningMode] No matching subtitle at position=${pos.inSeconds}s '
            '(have ${widget.subtitles.length} files). '
            'First cue starts at ${widget.subtitles.isNotEmpty && widget.subtitles.first.controller.subtitles.isNotEmpty ? widget.subtitles.first.controller.subtitles.first.start.inSeconds : "N/A"}s');
        _firstSubtitleLogged = true;
      }
      return;
    }

    final controller = widget.subtitles[bestMatch].controller;
    final subs = controller.subtitles;
    final newIndex = subs.indexWhere(
      (s) => s.start <= pos && s.end >= pos,
    );

    if (newIndex != -1 && newIndex != _currentIndex) {
      debugPrint('[MiningMode] ✅ Subtitle #$newIndex at ${pos.inSeconds}s: '
          '"${subs[newIndex].data.substring(0, subs[newIndex].data.length < 80 ? subs[newIndex].data.length : 80)}"');
      setState(() {
        _currentIndex = newIndex;
        _currentSubtitle = subs[newIndex];
      });

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
    try {
      final result = await widget.appModel.searchDictionary(
        searchTerm: word.trim(),
        searchWithWildcards: false,
      );

      if (!mounted) return;

      final headings = result.headings.toList();
      if (headings.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No results for "$word"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      _showDictionaryPopup(headings);
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

  /// Shows dictionary headings in a bottom sheet.
  void _showDictionaryPopup(List<DictionaryHeading> headings) {
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
            return ListView.builder(
              controller: scrollController,
              itemCount: headings.length,
              itemBuilder: (ctx, i) {
                return _buildDictionaryHeading(ctx, headings[i]);
              },
            );
          },
        );
      },
    );
  }

  /// Builds a dictionary heading with its entries.
  Widget _buildDictionaryHeading(BuildContext context, DictionaryHeading heading) {
    final entries = heading.entries.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
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
                heading.term,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (heading.reading.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  heading.reading,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          // Entries
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  entry.definitions.join('; '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              );
            }),
          ],
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

    return WillPopScope(
      onWillPop: () async {
        widget.onExitMining();
        return true;
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
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          // Subtitle info
          if (_currentIndex >= 0)
            Text(
              '#${_currentIndex + 1}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
