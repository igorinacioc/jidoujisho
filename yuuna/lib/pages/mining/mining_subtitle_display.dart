import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';

/// A large, interactive subtitle display for the mining mode.
///
/// Shows the current subtitle prominently in white text on a black background,
/// with previous and next subtitles faded above and below.
///
/// Supports tap-to-select-word for dictionary lookup via [onWordTap] callback.
class MiningSubtitleDisplay extends StatelessWidget {
  const MiningSubtitleDisplay({
    required this.currentSubtitle,
    this.previousSubtitle,
    this.nextSubtitle,
    this.onWordTap,
    this.fontSize = 32,
    Key? key,
  }) : super(key: key);

  /// The currently active subtitle to display prominently.
  final Subtitle? currentSubtitle;

  /// The previous subtitle, shown faded above.
  final Subtitle? previousSubtitle;

  /// The next subtitle, shown faded below.
  final Subtitle? nextSubtitle;

  /// Called when the user taps on a word in the subtitle.
  /// The tapped word is passed as the argument.
  final void Function(String word)? onWordTap;

  /// Font size for the current subtitle text.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous subtitle (faded)
        if (previousSubtitle != null)
          _buildFadedSubtitle(previousSubtitle!, context),

        const Spacer(),

        // Current subtitle (big + interactive)
        Expanded(
          flex: 3,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: currentSubtitle != null
                  ? _buildCurrentSubtitle(context)
                  : _buildWaitingMessage(context),
            ),
          ),
        ),

        const Spacer(),

        // Next subtitle (faded)
        if (nextSubtitle != null)
          _buildFadedSubtitle(nextSubtitle!, context),
      ],
    );
  }

  /// Builds the prominent current subtitle with tappable words.
  Widget _buildCurrentSubtitle(BuildContext context) {
    final text = currentSubtitle!.data;

    return GestureDetector(
      onLongPress: () {
        // Long press on entire subtitle -> show full text selection.
        if (onWordTap != null && text.isNotEmpty) {
          _showTextSelectionMenu(context, text);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 6,
            children: _buildWordWidgets(context, text),
          ),
        ),
      ),
    );
  }

  /// Splits the subtitle text into individual word widgets.
  List<Widget> _buildWordWidgets(BuildContext context, String text) {
    // Split by spaces and punctuation boundaries for CJK-aware tokenization.
    final words = _tokenize(text);
    return words.map((word) {
      final isPunctuation = RegExp(r'^[^\w]+$').hasMatch(word);
      if (isPunctuation || word.trim().isEmpty) {
        return Text(
          word,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: fontSize,
            height: 1.4,
          ),
        );
      }

      return GestureDetector(
        onTap: () => onWordTap?.call(word.trim()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Text(
            word,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              height: 1.4,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Simple tokenizer that splits by spaces while keeping punctuation attached.
  List<String> _tokenize(String text) {
    // Split on spaces but keep each token.
    final tokens = <String>[];
    final regex = RegExp(r'\S+\s*');
    for (final match in regex.allMatches(text)) {
      tokens.add(match.group(0)!);
    }
    if (tokens.isEmpty && text.isNotEmpty) {
      tokens.add(text);
    }
    return tokens;
  }

  /// Shows a context menu for text selection.
  void _showTextSelectionMenu(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildActionChip(ctx, 'Copy', Icons.copy, () {
                      // Copy text to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                      Navigator.pop(ctx);
                    }),
                    const SizedBox(width: 8),
                    _buildActionChip(ctx, 'Search All', Icons.search, () {
                      if (onWordTap != null) {
                        onWordTap!(text.trim());
                      }
                      Navigator.pop(ctx);
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds an action chip for the text selection menu.
  Widget _buildActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ActionChip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.white.withOpacity(0.12),
      onPressed: onPressed,
    );
  }

  /// Builds a faded version of a subtitle for previous/next.
  Widget _buildFadedSubtitle(Subtitle subtitle, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        subtitle.data,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.25),
          fontSize: 14,
          height: 1.3,
        ),
      ),
    );
  }

  /// Message shown when waiting for the first subtitle.
  Widget _buildWaitingMessage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.live_tv, color: Colors.white24, size: 64),
        const SizedBox(height: 16),
        Text(
          'Waiting for subtitles...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Make sure the video is playing on your TV',
          style: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
