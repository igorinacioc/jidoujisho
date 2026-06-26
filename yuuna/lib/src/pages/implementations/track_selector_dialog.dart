import 'package:flutter/material.dart';
import 'package:yuuna/utils.dart';

/// A single track option displayed in the selector.
class TrackOption {
  /// Create a track option with [label] and optional [subtitle].
  const TrackOption({required this.label, this.subtitle});

  /// The main label shown for this track (e.g. language, codec).
  final String label;

  /// Optional secondary text (e.g. track index, codec details).
  final String? subtitle;
}

/// A Moonfin-inspired track selection dialog for audio and subtitle tracks.
///
/// Shows a styled dialog with radio-button indicators, labels, and optional
/// subtitles for each track. Returns the selected index.
class TrackSelectorDialog {
  TrackSelectorDialog._();

  /// Shows a track selection dialog.
  ///
  /// [title] is the dialog header (e.g. "Audio" or "Subtitles").
  /// [options] is the list of track entries.
  /// [selectedIndex] is the currently active index (highlighted with check).
  /// Returns the newly selected index, or null if cancelled.
  static Future<int?> show(
    BuildContext context, {
    required String title,
    required List<TrackOption> options,
    int? selectedIndex,
  }) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => _TrackSelectorContent(
        title: title,
        options: options,
        selectedIndex: selectedIndex,
      ),
    );
  }
}

// ─── Internal widgets ────────────────────────────────────────────────────────

class _TrackSelectorContent extends StatelessWidget {
  const _TrackSelectorContent({
    required this.title,
    required this.options,
    this.selectedIndex,
  });

  final String title;
  final List<TrackOption> options;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return AlertDialog(
      title: Text(title, style: theme.textTheme.titleLarge),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      actionsPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        width: 360,
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (_, i) => _TrackRow(
            option: options[i],
            isSelected: selectedIndex == i,
            onTap: () => Navigator.pop(context, i),
          ),
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
        ),
      ],
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final TrackOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : theme.unselectedWidgetColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
