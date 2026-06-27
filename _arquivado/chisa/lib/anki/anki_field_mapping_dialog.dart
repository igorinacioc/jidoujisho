import 'package:chisa/util/anki_creator.dart';
import 'package:flutter/material.dart';

/// Dialog for mapping jidoujisho export fields to Anki model fields.
///
/// Shows a list of jidoujisho fields paired with dropdowns for the user
/// to choose which Anki field each should map to.
class AnkiFieldMappingDialog extends StatefulWidget {
  final List<String> ankiFieldNames;
  final Map<String, String>? currentMapping;

  const AnkiFieldMappingDialog({
    super.key,
    required this.ankiFieldNames,
    this.currentMapping,
  });

  @override
  State<AnkiFieldMappingDialog> createState() => _AnkiFieldMappingDialogState();
}

class _AnkiFieldMappingDialogState extends State<AnkiFieldMappingDialog> {
  late Map<String, String> _mapping;

  static const List<_FieldDef> _jidoujishoFields = [
    _FieldDef(key: "sentence", label: "Sentence", icon: Icons.format_align_center),
    _FieldDef(key: "word", label: "Word", icon: Icons.speaker_notes_outlined),
    _FieldDef(key: "reading", label: "Reading", icon: Icons.surround_sound_outlined),
    _FieldDef(key: "meaning", label: "Meaning", icon: Icons.translate_rounded),
    _FieldDef(key: "image", label: "Image", icon: Icons.image),
    _FieldDef(key: "audio", label: "Audio", icon: Icons.audiotrack),
    _FieldDef(key: "extra", label: "Extra", icon: Icons.more_horiz),
    _FieldDef(key: "context", label: "Context", icon: Icons.link),
  ];

  @override
  void initState() {
    super.initState();
    _mapping = Map<String, String>.from(widget.currentMapping ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Field Mapping"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Map jidoujisho fields to Anki model fields:",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ..._jidoujishoFields.map((field) => _buildFieldRow(field)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Auto-map: match by name (case-insensitive)
            setState(() {
              for (final f in _jidoujishoFields) {
                final match = widget.ankiFieldNames.firstWhere(
                  (a) => a.toLowerCase().trim() == f.label.toLowerCase().trim(),
                  orElse: () => "",
                );
                if (match.isNotEmpty) {
                  _mapping[f.key] = match;
                }
              }
            });
          },
          child: const Text("Auto-Map"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _mapping),
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildFieldRow(_FieldDef field) {
    final mappedValue = _mapping[field.key] ?? "";
    final options = ["", ...widget.ankiFieldNames];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(field.icon, size: 20, color: Theme.of(context).unselectedWidgetColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(field.label, style: const TextStyle(fontSize: 13)),
          ),
          const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: options.contains(mappedValue) ? mappedValue : "",
              isExpanded: true,
              isDense: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(),
              ),
              items: options.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt.isEmpty ? "(ignore)" : opt,
                    style: TextStyle(
                      fontSize: 12,
                      color: opt.isEmpty ? Colors.grey : null,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  if (val != null && val.isNotEmpty) {
                    _mapping[field.key] = val;
                  } else {
                    _mapping.remove(field.key);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldDef {
  final String key;
  final String label;
  final IconData icon;
  const _FieldDef({required this.key, required this.label, required this.icon});
}
