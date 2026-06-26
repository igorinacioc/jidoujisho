import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:server_core/server_core.dart';
import 'package:server_jellyfin/server_jellyfin.dart';

// Set these via environment variables or edit locally before running.
// JELLYFIN_URL, JELLYFIN_USERNAME, JELLYFIN_PASSWORD
const serverUrl = String.fromEnvironment('JELLYFIN_URL', defaultValue: 'http://localhost:8096');
const username = String.fromEnvironment('JELLYFIN_USERNAME', defaultValue: '');
const password = String.fromEnvironment('JELLYFIN_PASSWORD', defaultValue: '');

void main() async {
  print('=== Jellyfin Live Test ===\n');
  final device = DeviceInfo(
    deviceId: 'test-${DateTime.now().millisecondsSinceEpoch}',
    deviceName: 'Test Runner',
    clientName: 'Yuuna Test',
    clientVersion: '2.9.0',
  );

  // 1. Auth
  print('1. Auth...');
  final client = JellyfinMediaServerClient(baseUrl: serverUrl, deviceInfo: device);
  final auth = await client.authApi.authenticateByName(username, password);
  client.setCredentials(accessToken: auth.accessToken, userId: auth.userId);
  print('   ✅ User: ${auth.userName}  Id: ${auth.userId}');

  // 2. Raw HTTP test (server info, views, items)
  print('\n2. Raw HTTP test...');
  final dio = Dio(BaseOptions(baseUrl: serverUrl));
  dio.options.headers['X-Emby-Authorization'] = buildAuthHeader(
    deviceInfo: device, accessToken: auth.accessToken,
  );

  // Server info
  try {
    final info = await dio.get('/System/Info');
    final m = info.data as Map;
    print('   Server: ${m['ServerName']} v${m['Version']}');
  } catch (e) {
    print('   Server info: $e');
  }

  // Views
  var resp = await dio.get('/Users/${auth.userId}/Views');
  print('   Views: HTTP ${resp.statusCode} — ${((resp.data as Map)['Items'] as List).length} views');

  // Items with MediaSources + MediaStreams
  resp = await dio.get('/Users/${auth.userId}/Items', queryParameters: {
    'Recursive': 'true', 'Limit': '2',
    'IncludeItemTypes': 'Movie,Episode',
    'Fields': 'MediaSources,MediaStreams,Overview',
  });
  print('   Items: HTTP ${resp.statusCode}');
  final items = (resp.data as Map)['Items'] as List;
  for (final i in items) {
    final m = i as Map;
    final srcs = (m['MediaSources'] as List?) ?? [];
    final streams = (m['MediaStreams'] as List?) ?? [];
    final subs = streams.where((s) => (s as Map)['Type'] == 'Subtitle').toList();
    print('   📺 ${m['Name']} (${m['Type']}) id=${m['Id']}');
    print('      MediaSources: ${srcs.length}  Streams: ${streams.length}  Subtitles: ${subs.length}');
  }

  // 2b. Subtitle: test with Stream.vtt (Jellyfin 10.11+ format)
  print('\n2b. Subtitle test (WebVTT)...');
  if (items.isNotEmpty) {
    final first = items[0] as Map;
    final srcs = (first['MediaSources'] as List?) ?? [];
    final streams = (first['MediaStreams'] as List?) ?? [];
    final subs = streams.where((s) => (s as Map)['Type'] == 'Subtitle').toList();
    if (srcs.isNotEmpty && subs.isNotEmpty) {
      final itemId = first['Id'];
      final srcId = (srcs[0] as Map)['Id'];
      final s = subs.first as Map;
      final idx = s['Index'];
      print('   Sub[$idx] ${s['Codec']} lang=${s['Language']} title=${s['DisplayTitle']}');
      try {
        final r = await dio.get(
          '/Videos/$itemId/$srcId/Subtitles/$idx/Stream.vtt',
          queryParameters: {'api_key': auth.accessToken},
          options: Options(responseType: ResponseType.plain),
        );
        final body = r.data as String;
        print('   ✅ HTTP ${r.statusCode} ${body.length} chars');
        // Show first dialogue line
        final lines = body.split('\n')
            .where((l) => l.isNotEmpty && !l.startsWith('WEBVTT') && !l.startsWith('Region:') && !l.contains('-->'))
            .toList();
        if (lines.isNotEmpty) print('   Preview: ${lines.first}');
      } catch (e) {
        print('   ❌ ${e.toString().split('\n')[0]}');
      }
    }
  }

  // 3. Client API test
  print('\n3. Client API test...');
  try {
    final views = await client.itemsApi.getViews();
    print('   Views via client: ${views.length}');
    if (views.isNotEmpty) {
      final mediaItems = await client.itemsApi.getItems(views.first.id, limit: 2);
      print('   Items via client: ${mediaItems.length}');
      for (final item in mediaItems) {
        print('   🎬 ${item.name} (${item.type})');
        print('      Sources: ${item.mediaSources.length}, Streams: ${item.mediaStreams.length}');
        if (item.mediaSources.isNotEmpty) {
          final url = client.playbackApi.getStreamUrl(item.id, item.mediaSources.first.id);
          print('      Stream: $url');
        }
        final subs = item.mediaStreams.where((s) => s.type == 'Subtitle').toList();
        if (subs.isNotEmpty && item.mediaSources.isNotEmpty) {
          print('      Subtitles: ${subs.length} tracks');
          try {
            final content = await client.playbackApi.getSubtitleContent(
              item.id, item.mediaSources.first.id, subs[0].index,
            );
            print('      ✅ Sub OK: ${content.length} chars (${subs[0].codec})');
            // Show first dialogue
            final lines = content.split('\n')
                .where((l) => l.isNotEmpty && !l.startsWith('WEBVTT') && !l.startsWith('Region:') && !l.contains('-->'))
                .toList();
            if (lines.isNotEmpty) print('      Preview: ${lines.first}');
          } catch (e) {
            print('      ❌ Sub: $e');
          }
        }
      }
    }
  } catch (e) {
    print('   ❌ Client API error: $e');
  }

  client.dispose();
  print('\n=== Done ===');
}
