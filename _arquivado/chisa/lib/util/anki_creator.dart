import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_backend.dart' as backend;
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

// ─── Re-exports from unified backend ───────────────────────────────────────

/// Request permissions from AnkiDroid (Android only, no-op on desktop).
Future<void> requestAnkiDroidPermissions() =>
    backend.requestAnkiDroidPermissions();

/// Get list of deck names from Anki.
Future<List<String>> getDecks() => backend.getDecks();

/// Get all note types (models) with their field names.
Future<Map<String, List<String>>> getModels() => backend.getModels();

/// Get field names for a specific model.
Future<List<String>> getModelFields(String modelName, {int minFields = 1}) =>
    backend.getModelFields(modelName, minFields: minFields);

/// Create a new note type (model) in Anki.
Future<String?> addNewModel(String modelName, List<String> fieldNames) =>
    backend.addNewModel(modelName, fieldNames);

/// Add media file to Anki's media collection.
Future<String> addMediaFromUri(
    String fileUriPath, String preferredName, String mimeType) =>
    backend.addMediaFromUri(fileUriPath, preferredName, mimeType);

/// Check if AnkiConnect is available (desktop).
Future<bool> isAnkiConnectAvailable() => backend.isAnkiConnectAvailable();

/// Add a note to Anki with custom model and field mapping.
Future<void> addNote({
  String deck = "Default",
  required AnkiExportParams params,
  String? modelName,
  Map<String, String>? fieldMapping,
}) => backend.addNote(
  deck: deck,
  params: params,
  modelName: modelName,
  fieldMapping: fieldMapping,
);

// ─── Navigation ────────────────────────────────────────────────────────────

Future<void> navigateToCreator({
  required BuildContext context,
  required AppModel appModel,
  AnkiExportParams? initialParams,
  bool editMode = false,
  bool autoMode = false,
  Color? backgroundColor,
  Color? appBarColor,
  bool popOnExport = false,
  bool hideActions = false,
  Function()? exportCallback,
  ThemeData? themeData,
}) async {
  try {
    List<String> decks = await getDecks();

    Future<Widget> buildCreatorPage() async {
      return Future.microtask(() {
        return CreatorPage(
          initialParams: initialParams,
          backgroundColor: backgroundColor,
          appBarColor: appBarColor,
          decks: decks,
          autoMode: autoMode,
          editMode: editMode,
          popOnExport: popOnExport,
          hideActions: hideActions,
          exportCallback: exportCallback,
        );
      });
    }

    Widget creatorPage = await buildCreatorPage();

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => (themeData != null)
            ? Theme(data: themeData, child: creatorPage)
            : creatorPage,
      ),
    );
  } catch (e) {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: Text(
            appModel.translate("ankidroid_api"),
          ),
          content: Text(
            appModel.translate("ankidroid_api_message"),
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                appModel.translate("dialog_launch_ankidroid"),
              ),
              onPressed: () async {
                DeviceApps.openApp('com.ichi2.anki');
                Navigator.pop(context);

                try {
                  List<String> decks = await getDecks();
                  Future<Widget> buildCreatorPage() async {
                    return Future.microtask(() {
                      return CreatorPage(
                        initialParams: initialParams,
                        backgroundColor: backgroundColor,
                        appBarColor: appBarColor,
                        decks: decks,
                        autoMode: autoMode,
                        editMode: editMode,
                        popOnExport: popOnExport,
                        exportCallback: exportCallback,
                      );
                    });
                  }

                  Widget creatorPage = await buildCreatorPage();
                  await Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (_, __, ___) => (themeData != null)
                          ? Theme(data: themeData, child: creatorPage)
                          : creatorPage,
                    ),
                  );
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
            ),
          ],
        );
      },
    );
    debugPrint(e.toString());
  }
}
