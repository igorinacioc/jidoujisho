import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Unified Anki backend that works on both:
/// - Android: uses AnkiDroid MethodChannel API
/// - Desktop/Windows: uses AnkiConnect (Anki Desktop HTTP API)
///
/// Auto-detects platform and routes calls accordingly.

const MethodChannel ankiDroidMethodChannel =
    MethodChannel('com.arianneorpilla.api/ankidroid');

/// Base URL for AnkiConnect on desktop (Anki Desktop plugin).
/// Default: http://localhost:8765
const String ankiConnectUrl = 'http://localhost:8765';

/// Whether we're running on a platform that has AnkiDroid.
bool get isAndroidPlatform => defaultTargetPlatform == TargetPlatform.android;

// ─── Public API ────────────────────────────────────────────────────────────

Future<void> requestAnkiDroidPermissions() async {
  if (isAndroidPlatform) {
    await ankiDroidMethodChannel.invokeMethod('requestPermissions');
  }
  // Desktop: no permissions needed for AnkiConnect
}

Future<List<String>> getDecks() async {
  if (isAndroidPlatform) {
    Map<dynamic, dynamic> deckMap =
        await ankiDroidMethodChannel.invokeMethod('getDecks');
    List<String> decks = deckMap.values.toList().cast<String>();
    decks.sort((a, b) => a.compareTo(b));
    return decks;
  } else {
    return await _ankiConnectCall('deckNames', {});
  }
}

/// Fetches all available note types (models).
/// Returns a map: modelName → list of field names.
Future<Map<String, List<String>>> getModels() async {
  if (isAndroidPlatform) {
    try {
      Map<dynamic, dynamic> modelMap =
          await ankiDroidMethodChannel.invokeMethod('getModels');
      Map<String, List<String>> result = {};
      modelMap.forEach((key, value) {
        result[key.toString()] = (value as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      });
      return result;
    } on PlatformException {
      return {};
    }
  } else {
    // AnkiConnect: get model names, then get fields for each
    try {
      List<String> modelNames =
          await _ankiConnectCall('modelNames', {});
      Map<String, List<String>> result = {};
      for (final name in modelNames) {
        final fields = await getModelFields(name);
        if (fields.isNotEmpty) {
          result[name] = fields;
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }
}

/// Fetches field names for a specific model.
Future<List<String>> getModelFields(String modelName,
    {int minFields = 1}) async {
  if (isAndroidPlatform) {
    try {
      List<dynamic> fieldList = await ankiDroidMethodChannel
          .invokeMethod('getModelFields', <String, dynamic>{
        'modelName': modelName,
        'minFields': minFields,
      });
      return fieldList.map((e) => e.toString()).toList();
    } on PlatformException {
      return [];
    }
  } else {
    try {
      final fields = await _ankiConnectCall('modelFieldNames', {
        'modelName': modelName,
      });
      return fields.where((f) => true).cast<String>().toList();
    } catch (_) {
      return [];
    }
  }
}

/// Creates a new note type (model) in Anki with the given fields.
/// Returns the model name on success, null on failure.
Future<String?> addNewModel(String modelName, List<String> fieldNames) async {
  if (isAndroidPlatform) {
    try {
      String? result = await ankiDroidMethodChannel
          .invokeMethod('addNewModel', <String, dynamic>{
        'modelName': modelName,
        'fieldNames': fieldNames,
      });
      return result;
    } on PlatformException {
      return null;
    }
  } else {
    try {
      // AnkiConnect: createModel
      // Card template: front = first field, back = all fields
      final cardFront = fieldNames
          .map((f) =>
              '<div class="{{f.toLowerCase()}}">{{$f}}</div>')
          .join('\n');
      final cardBack = '{{FrontSide}}\n<hr id=answer>\n' +
          fieldNames
              .map((f) =>
                  '<div class="{{f.toLowerCase()}}">{{$f}}</div>')
              .join('\n');

      await _ankiConnectCall('createModel', {
        'modelName': modelName,
        'inOrderFields': fieldNames,
        'cardTemplates': [
          {
            'Name': '$modelName Card',
            'Front': cardFront,
            'Back': cardBack,
          }
        ],
        'css': '.card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }',
      });
      return modelName;
    } catch (e) {
      debugPrint("Failed to create model via AnkiConnect: $e");
      return null;
    }
  }
}

/// Adds a media file to Anki's media collection.
/// Returns the filename as stored in Anki.
Future<String> addMediaFromUri(
  String fileUriPath,
  String preferredName,
  String mimeType,
) async {
  if (isAndroidPlatform) {
    try {
      return await ankiDroidMethodChannel
          .invokeMethod('addMediaFromUri', <String, dynamic>{
        'fileUriPath': fileUriPath,
        'preferredName': preferredName,
        'mimeType': mimeType,
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to add media from URI");
      debugPrint(e.toString());
    }
    return "";
  } else {
    // AnkiConnect: storeMediaFile
    try {
      final file = File(fileUriPath.replaceFirst('file:///', ''));
      if (file.existsSync()) {
        final bytes = await file.readAsBytes();
        final base64Data = base64Encode(bytes);
        final filename = await _ankiConnectCall('storeMediaFile', {
          'filename': preferredName,
          'data': base64Data,
        });
        return filename ?? preferredName;
      }
    } catch (e) {
      debugPrint("Failed to store media via AnkiConnect: $e");
    }
    return "";
  }
}

/// Adds a note to Anki using the specified model and field mapping.
Future<void> addNote({
  String deck = "Default",
  required dynamic params, // AnkiExportParams
  String? modelName,
  Map<String, String>? fieldMapping,
}) async {
  try {
    final p = params; // AnkiExportParams

    DateTime now = DateTime.now();
    String newFileName =
        "jidoujisho-" +
        "${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}T"
        "${now.hour.toString().padLeft(2,'0')}${now.minute.toString().padLeft(2,'0')}${now.second.toString().padLeft(2,'0')}";

    String image = "";
    String audio = "";

    if (p.imageFile != null && p.imageFile!.existsSync()) {
      image = await addMediaFromUri(
        "file:///${p.imageFile!.path}",
        newFileName,
        "image",
      );
      debugPrint("IMAGE FILE EXPORTED: $image");
    }

    if (p.audioFile != null && p.audioFile!.existsSync()) {
      audio = await addMediaFromUri(
        "file:///${p.audioFile!.path}",
        newFileName,
        "audio",
      );
      debugPrint("AUDIO FILE EXPORTED: $audio");
    }

    String sentence = p.sentence ?? "";
    String word = p.word ?? "";
    String reading = p.reading ?? "";
    String meaning = p.meaning ?? "";
    String extra = p.extra ?? "";
    String context = p.context ?? "";

    String zeroWidthSpace = "​";
    if (sentence.isEmpty) sentence = zeroWidthSpace;
    if (word.isEmpty) word = zeroWidthSpace;
    if (reading.isEmpty) reading = zeroWidthSpace;
    if (meaning.isEmpty) meaning = zeroWidthSpace;
    if (extra.isEmpty) extra = zeroWidthSpace;

    // Build mapped fields
    Map<String, String> mappedFields;
    if (fieldMapping != null && fieldMapping.isNotEmpty) {
      mappedFields = {};
      final jidoujishoValues = <String, String>{
        "sentence": sentence,
        "word": word,
        "reading": reading,
        "meaning": meaning,
        "image": image,
        "audio": audio,
        "extra": extra,
        "context": context,
      };
      for (final entry in fieldMapping.entries) {
        final jidoujishoKey = entry.key;
        final ankiFieldName = entry.value;
        mappedFields[ankiFieldName] =
            jidoujishoValues[jidoujishoKey] ?? "";
      }
    } else {
      // Default mapping for "jidoujisho Chisa"
      mappedFields = {
        "Sentence": sentence,
        "Word": word,
        "Reading": reading,
        "Meaning": meaning,
        "Image": image,
        "Audio": audio,
        "Extra": extra,
        "Context": context,
      };
    }

    if (isAndroidPlatform) {
      await ankiDroidMethodChannel.invokeMethod('addNote', <String, dynamic>{
        'deck': deck,
        'modelName': modelName,
        'sentence': sentence,
        'word': word,
        'reading': reading,
        'meaning': meaning,
        'image': image,
        'audio': audio,
        'extra': extra,
        'contextParam': context,
        'fields': mappedFields,
      });
    } else {
      // AnkiConnect: addNote
      final ankiFields = <String, String>{};
      for (final entry in mappedFields.entries) {
        ankiFields[entry.key] = entry.value;
      }

      final effectiveModelName =
          (modelName != null && modelName.isNotEmpty)
              ? modelName
              : "jidoujisho Chisa";

      // Ensure the model exists on desktop too
      await _ensureDefaultModelExists(effectiveModelName);

      await _ankiConnectCall('addNote', {
        'note': {
          'deckName': deck,
          'modelName': effectiveModelName,
          'fields': ankiFields,
          'tags': ['Chisa'],
        },
      });
      debugPrint("Added note via AnkiConnect to deck: $deck, model: $effectiveModelName");
    }
  } catch (e) {
    debugPrint("Failed to add note: $e");
  }
}

/// Ensures the default "jidoujisho Chisa" model exists on desktop.
Future<void> _ensureDefaultModelExists(String modelName) async {
  if (modelName == "jidoujisho Chisa") {
    try {
      final models = await getModels();
      if (!models.containsKey("jidoujisho Chisa")) {
        await addNewModel("jidoujisho Chisa", [
          "Sentence", "Word", "Reading", "Meaning",
          "Image", "Audio", "Extra", "Context",
        ]);
        debugPrint("Created default jidoujisho Chisa model via AnkiConnect");
      }
    } catch (_) {}
  }
}

// ─── AnkiConnect HTTP client ───────────────────────────────────────────────

/// Makes a JSON-RPC call to AnkiConnect.
/// AnkiConnect runs as an Anki Desktop plugin at http://localhost:8765.
Future<dynamic> _ankiConnectCall(String action, Map<String, dynamic> params) async {
  final body = jsonEncode({
    'action': action,
    'version': 6,
    'params': params,
  });

  final response = await http.post(
    Uri.parse(ankiConnectUrl),
    headers: {'Content-Type': 'application/json'},
    body: body,
  ).timeout(const Duration(seconds: 5));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['error'] != null) {
      throw Exception('AnkiConnect error: ${data['error']}');
    }
    return data['result'];
  } else {
    throw Exception(
        'AnkiConnect not reachable. Is Anki Desktop open with AnkiConnect plugin?');
  }
}

/// Quick check if AnkiConnect is available.
Future<bool> isAnkiConnectAvailable() async {
  try {
    await _ankiConnectCall('version', {});
    return true;
  } catch (_) {
    return false;
  }
}
