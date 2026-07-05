import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/cast/cast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A source for the [PlayerMediaType], which handles primarily video-based
/// media.
abstract class PlayerMediaSource extends MediaSource {
  /// Initialise a media source.
  PlayerMediaSource({
    required super.uniqueKey,
    required super.sourceName,
    required super.description,
    required super.icon,
    required super.implementsSearch,
    required super.implementsHistory,
  }) : super(
          mediaType: PlayerMediaType.instance,
          overridesAutoAudio: true,
          overridesAutoImage: true,
        );

  @override
  double get aspectRatio => 16 / 9;

  /// The body widget to show in the tab when this source's media type and this
  /// source is selected.
  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const HistoryPlayerPage();
  }

  /// It may be useful to do multiple operations at the same time, so this
  /// is used before preparing the controller and subtitles.
  Future<void> prepareMediaResources({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {}

  /// Get the player controller to be used when a media item is loaded up.
  /// Returns a [UniversalPlayerController] (wraps VLC or media_kit).
  Future<UniversalPlayerController> preparePlayerController({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    throw UnimplementedError();
  }

  /// Get the player controller to be used when a media item is loaded up,
  Future<List<SubtitleItem>> prepareSubtitles({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> onSourceExit({
    required AppModel appModel,
    required WidgetRef ref,
  }) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// The current selected subtitle in the transcript in order to generate
  /// the right image.
  Subtitle? _transcriptSubtitle;

  /// Set the transcript subtitle.
  void setTranscriptSubtitle(Subtitle subtitle) {
    _transcriptSubtitle = subtitle;
  }

  /// Clear the transcript subtitle.
  void clearTranscriptSubtitle() {
    _transcriptSubtitle = null;
  }

  /// If this source is non-null, this will be used as the initial function
  /// for the image field over the auto enhancement. Extra durations can be
  /// invoked and defined when initially opening the creator, to call attention
  /// to multiple durations to be used for image generation.
  @override
  Future<List<NetworkToFileImage>> generateImages({
    required AppModel appModel,
    required MediaItem item,
    List<Subtitle>? subtitles,
    SubtitleOptions? options,
    String? data,
  }) async {
    while (appModel.blockCreatorInitialMedia) {
      await Future.delayed(const Duration(seconds: 1), () {});
    }

    if (appModel.isProcessingEmbeddedSubtitles) {
      Fluttertoast.showToast(msg: t.processing_embedded_subtitles);
      return [];
    }

    bool useCurrentTime = false;
    if (subtitles == null && _transcriptSubtitle != null) {
      subtitles = [_transcriptSubtitle!];
      debugPrint('[Mining:img] Using _transcriptSubtitle (${subtitles.length} cues)');
    }

    if (subtitles == null && appModel.currentSubtitle.value != null) {
      subtitles ??= [appModel.currentSubtitle.value!];
      useCurrentTime = true;
      debugPrint('[Mining:img] Using currentSubtitle (useCurrentTime=true)');
    }

    if (subtitles == null || subtitles.isEmpty) {
      debugPrint('[Mining:img] ❌ No subtitles available — '
          '_transcriptSubtitle=${_transcriptSubtitle != null} '
          'currentSubtitle=${appModel.currentSubtitle.value != null} '
          'currentPlayerController=${appModel.currentPlayerController != null}');
      return [];
    }

    debugPrint('[Mining:img] Generating ${subtitles.length} image(s) from '
        'mediaIdentifier=${item.mediaIdentifier.substring(0, item.mediaIdentifier.length < 80 ? item.mediaIdentifier.length : 80)}...');

    List<NetworkToFileImage> imageFiles = [];
    Directory appDirDoc = await getApplicationSupportDirectory();
    String playerPreviewPath = '${appDirDoc.path}/playerImagePreview';
    Directory playerPreviewDir = Directory(playerPreviewPath);
    if (playerPreviewDir.existsSync()) {
      playerPreviewDir.deleteSync(recursive: true);
    }
    playerPreviewDir.createSync();

    String dirTimestamp = DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    Directory imageDir = Directory('$playerPreviewPath/$dirTimestamp');
    imageDir.createSync();

    for (int index = 0; index < subtitles.length; index++) {
      Subtitle subtitle = subtitles[index];
      File imageFile = appModel.getPreviewImageFile(imageDir, index);

      String outputPath = imageFile.path;
      if (imageFile.existsSync()) {
        imageFile.deleteSync();
      }

      int msStart = subtitle.start.inMilliseconds;
      int msEnd = subtitle.end.inMilliseconds;
      int msMean = ((msStart + msEnd) / 2).floor();
      Duration currentTime = Duration(milliseconds: msMean);

      // Null-safe: player may not exist during DLNA cast sessions.
      final playerController = appModel.currentPlayerController;
      if (useCurrentTime && playerController != null) {
        currentTime = Duration(
            milliseconds: playerController.value.position.inMilliseconds);
        debugPrint('[Mining:img] Using current player position: ${currentTime.inSeconds}s');
      }

      String ffmpegTimestamp = JidoujishoTimeFormat.getFfmpegTimestamp(currentTime);
      String inputPath = item.mediaIdentifier;
      MediaSource source = item.getMediaSource(appModel: appModel);
      if (source is PlayerYoutubeSource) {
        inputPath = await source.getDataSource(item);
      }

      String command =
          '-ss $ffmpegTimestamp -y -i "$inputPath" -frames:v 1 -q:v 2 "$outputPath';

      debugPrint('[Mining:img] FFmpeg: $command');
      final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
      await flutterFFmpeg.execute(command);

      String output = await FlutterFFmpegConfig().getLastCommandOutput();
      debugPrint('[Mining:img] FFmpeg output (${output.length} chars): '
          '${output.substring(0, output.length < 120 ? output.length : 120)}');

      if (!output.contains('Output file is empty, nothing was encoded')) {
        while (!imageFile.existsSync()) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        NetworkToFileImage networkToFileImage =
            NetworkToFileImage(file: imageFile);

        imageFiles.add(networkToFileImage);
        debugPrint('[Mining:img] ✅ Image saved: ${imageFile.path}');
      } else {
        debugPrint('[Mining:img] ❌ FFmpeg produced empty output for subtitle $index');
      }
    }

    debugPrint('[Mining:img] Done: ${imageFiles.length}/${subtitles.length} images extracted');
    return imageFiles;
  }

  /// If this source is non-null, this will be used as the initial function
  /// for the audio field over the auto enhancement.
  @override
  Future<File?>? generateAudio({
    required AppModel appModel,
    required MediaItem item,
    List<Subtitle>? subtitles,
    SubtitleOptions? options,
    String? data,
  }) async {
    while (appModel.blockCreatorInitialMedia) {
      await Future.delayed(const Duration(seconds: 1), () {});
    }

    if (appModel.isProcessingEmbeddedSubtitles) {
      debugPrint('[Mining:audio] ⚠️ Blocked — embedded subtitles processing');
      return null;
    }

    debugPrint('[Mining:audio] Starting audio extraction...');

    Directory appDirDoc = await getApplicationSupportDirectory();
    String playerPreviewPath = '${appDirDoc.path}/playerAudioPreview';
    Directory playerPreviewDir = Directory(playerPreviewPath);
    if (playerPreviewDir.existsSync()) {
      playerPreviewDir.deleteSync(recursive: true);
    }
    playerPreviewDir.createSync();

    File audioFile = appModel.getAudioPreviewFile(playerPreviewDir);
    String outputPath = audioFile.path;
    if (audioFile.existsSync()) {
      audioFile.deleteSync();
    }

    // ── Audio track index (null-safe for DLNA cast sessions) ─────────
    int audioIndex = 0;
    final playerController = appModel.currentPlayerController;
    if (playerController != null) {
      final embeddedTracks = await playerController.getAudioTracks();
      audioIndex = await playerController.getAudioTrack() ?? 0;
      for (int i = 0; i < embeddedTracks.length; i++) {
        final entry = embeddedTracks.entries.elementAt(i);
        if (audioIndex == entry.key) {
          audioIndex = i;
        }
      }
      debugPrint('[Mining:audio] Audio index=$audioIndex tracks=${embeddedTracks.length}');
    } else {
      debugPrint('[Mining:audio] ⚠️ No VLC player controller — using audioIndex=0');
    }

    // ── Subtitle selection ───────────────────────────────────────────
    final allowance = Duration(milliseconds: options!.audioAllowance);
    final delay = Duration(milliseconds: options.subtitleDelay);

    if (subtitles == null && _transcriptSubtitle != null) {
      subtitles = [_transcriptSubtitle!];
      debugPrint('[Mining:audio] Using _transcriptSubtitle (${subtitles.length} cues)');
    }

    if (subtitles == null && appModel.currentSubtitle.value != null) {
      subtitles ??= [appModel.currentSubtitle.value!];
      debugPrint('[Mining:audio] Using currentSubtitle');
    }

    if (subtitles == null || subtitles.isEmpty) {
      debugPrint('[Mining:audio] ❌ No subtitles available — '
          '_transcriptSubtitle=${_transcriptSubtitle != null} '
          'currentSubtitle=${appModel.currentSubtitle.value != null} '
          'playerController=${playerController != null}');
      return null;
    }

    final adjustedStart = subtitles.first.start - delay - allowance;
    final adjustedEnd = subtitles.last.end - delay + allowance;
    final timeStart = JidoujishoTimeFormat.getFfmpegTimestamp(adjustedStart);
    final timeEnd = JidoujishoTimeFormat.getFfmpegTimestamp(adjustedEnd);

    debugPrint('[Mining:audio] Range: $timeStart → $timeEnd '
        '(allowance=${allowance.inMilliseconds}ms delay=${delay.inMilliseconds}ms)');

    String inputPath = item.mediaIdentifier;

    MediaSource source = item.getMediaSource(appModel: appModel);
    if (source is PlayerYoutubeSource) {
      inputPath =
          await source.getAudioExportUrl(item, playerController?.dataSource ?? '');
      audioIndex = 0;
    }

    String command =
        '-ss $timeStart -to $timeEnd -y -i "$inputPath" -map 0:a:$audioIndex "$outputPath"';

    debugPrint('[Mining:audio] FFmpeg: $command');
    final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
    await flutterFFmpeg.execute(command);

    if (audioFile.existsSync()) {
      debugPrint('[Mining:audio] ✅ Audio saved: ${audioFile.path} '
          '(${(audioFile.lengthSync() / 1024).toStringAsFixed(1)} KB)');
      return audioFile;
    } else {
      debugPrint('[Mining:audio] ❌ Audio file not created');
      return null;
    }
  }

  /// Open the [PlayerSettingsDialogPage].
  Widget buildSettingsButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.settings,
        icon: Icons.settings,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const PlayerSettingsDialogPage(),
          );
        },
      ),
    );
  }
}
