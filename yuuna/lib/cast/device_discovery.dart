import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_cast_dlna/media_cast_dlna.dart';
import 'package:server_core/server_core.dart';

import 'cast_models.dart';
import 'chromecast_discovery.dart';
import 'dlna_discovery_service.dart';

/// Discovers cast targets on the local network using three independent methods:
///
/// 1. **DLNA (jUPnP via media_cast_dlna)** — finds UPnP MediaRenderers
///    (Samsung, LG, Fire TV, Roku, and any DLNA-certified TV).
/// 2. **Chromecast mDNS** — finds Google Cast devices via `_googlecast._tcp.local`.
/// 3. **Jellyfin API** — lists Jellyfin-registered clients (Android TV, etc.).
///
/// Results are merged into a unified [CastTarget] list for the picker UI.
class DeviceDiscovery {
  static const _mdnsTimeout = Duration(seconds: 8);

  final SessionApi _sessionApi;
  DlnaDiscoveryService? _dlnaService;

  DeviceDiscovery(this._sessionApi);

  /// Ensures the DLNA discovery service is initialized (one-time).
  Future<DlnaDiscoveryService> _getDlnaService() async {
    _dlnaService ??= DlnaDiscoveryService();
    await _dlnaService!.initialize();
    return _dlnaService!;
  }

  /// Discovers all available cast targets across DLNA, Chromecast, and Jellyfin.
  Future<List<CastTarget>> discover() async {
    debugPrint('[Discovery] Starting device discovery...');

    // Start DLNA early (event-driven, runs in background).
    final dlnaFuture = _getDlnaService().then((s) => s.discover());

    final results = await Future.wait([
      dlnaFuture,
      _discoverChromecastDevices(),
      _discoverJellyfinDevices(),
    ]);

    final dlna = results[0] as List<DlnaDevice>;
    final cc = results[1] as List<DiscoveredDevice>;
    final jf = results[2] as List<ServerDevice>;

    debugPrint('[Discovery] Results: DLNA=${dlna.length} Chromecast=${cc.length} Jellyfin=${jf.length}');
    for (final d in dlna) {
      debugPrint('[Discovery] DLNA: "${d.friendlyName}" [${d.manufacturerDetails.manufacturer}]');
    }
    for (final d in cc) {
      debugPrint('[Discovery] Chromecast: "${d.name}" ip=${d.ip} port=${d.port}');
    }
    for (final d in jf) {
      debugPrint('[Discovery] Jellyfin: "${d.name}" app=${d.appName}');
    }

    final merged = _mergeDevices(dlna, jf, cc);
    debugPrint('[Discovery] Total merge targets: ${merged.length}');
    return merged;
  }

  // ─── Chromecast (mDNS) ─────────────────────────────────────────────────

  Future<List<DiscoveredDevice>> _discoverChromecastDevices() async {
    try {
      final cc = await ChromecastDiscovery.discover().timeout(_mdnsTimeout);
      return cc
          .map((c) => DiscoveredDevice(
                name: c.name,
                type: 'Google Cast',
                iconType: CastDeviceIcon.cast,
                ip: c.host,
                port: c.port,
                isChromecast: true,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Jellyfin API ──────────────────────────────────────────────────────

  Future<List<ServerDevice>> _discoverJellyfinDevices() async {
    try {
      final d = await _sessionApi.getDevices();
      return d.where((x) => _isCastDevice(x)).toList();
    } catch (_) {
      return [];
    }
  }

  bool _isCastDevice(ServerDevice d) {
    final a = d.appName?.toLowerCase() ?? '';
    final n = d.name.toLowerCase();
    // Exclude: web/mobile clients, and ourselves (Yuuna/jidoujisho).
    for (final w in [
      'web', 'browser', 'mobile', 'html', 'desktop', 'phone', 'tablet',
      'yuuna', 'jidoujisho',
    ]) {
      if (a.contains(w) || n.contains(w)) return false;
    }
    for (final p in [
      'chromecast', 'android tv', 'google tv', 'fire tv', 'firestick',
      'amazon', 'samsung', 'tizen', 'lg tv', 'webos', 'roku', 'apple tv',
      'shield', 'xbox', 'playstation', 'ps4', 'ps5', 'tv', 'television',
      'cast', 'dlna', 'raspberry', 'kodi', 'plex',
    ]) {
      if (a.contains(p) || n.contains(p)) return true;
    }
    return a.isNotEmpty && a != 'unknown' && a != 'android' && a != 'ios';
  }

  // ─── Merge ─────────────────────────────────────────────────────────────

  List<CastTarget> _mergeDevices(
    List<DlnaDevice> dlna,
    List<ServerDevice> jf,
    List<DiscoveredDevice> cc,
  ) {
    final tg = <CastTarget>[];
    final sn = <String>{};

    // 1. Chromecast devices first (preferred for Google Cast).
    for (final d in cc) {
      final k = d.name.toLowerCase();
      if (!sn.contains(k)) {
        sn.add(k);
        tg.add(CastTarget(
          name: d.name,
          type: d.type,
          icon: d.iconType,
          ssdpDevice: d,
        ));
      }
    }

    // 2. Jellyfin devices — try to match with DLNA and Chromecast.
    for (final d in jf) {
      final k = d.name.toLowerCase();
      if (sn.contains(k)) continue;
      sn.add(k);

      // Match Jellyfin device with a DLNA device by name/IP.
      DlnaDevice? matchedDlna;
      for (final dl in dlna) {
        if (_simNames(dl.friendlyName, d.name) ||
            dl.ipAddress.value == d.id ||
            dl.ipAddress.value == d.lastUserName) {
          matchedDlna = dl;
          break;
        }
      }

      tg.add(CastTarget(
        name: d.name,
        type: d.appName ?? 'Jellyfin Client',
        icon: CastDeviceIcon.tv,
        jellyfinDevice: d,
        dlnaDevice: matchedDlna,
      ));
    }

    // 3. Remaining DLNA devices (not matched to Jellyfin).
    for (final d in dlna) {
      final k = d.friendlyName.toLowerCase();
      if (sn.contains(k)) continue;
      sn.add(k);

      final type = _classifyDlnaDevice(d);
      tg.add(CastTarget(
        name: d.friendlyName,
        type: type,
        icon: CastDeviceIcon.tv,
        dlnaDevice: d,
      ));
    }

    return tg;
  }

  /// Classifies a [DlnaDevice] into a human-readable type string.
  String _classifyDlnaDevice(DlnaDevice d) {
    final mfr = d.manufacturerDetails.manufacturer.toLowerCase();
    final model = d.modelDetails.modelName.toLowerCase();

    if (mfr.contains('samsung') || model.contains('samsung') || model.contains('tizen')) {
      return 'Samsung TV';
    }
    if (mfr.contains('lg') || model.contains('lg') || model.contains('webos')) {
      return 'LG TV';
    }
    if (mfr.contains('amazon') || model.contains('fire') || model.contains('aft')) {
      return 'Fire TV';
    }
    if (mfr.contains('roku') || model.contains('roku')) {
      return 'Roku';
    }
    if (mfr.contains('sony') || model.contains('sony') || model.contains('bravia')) {
      return 'Sony TV';
    }
    if (mfr.contains('google') || model.contains('chromecast')) {
      return 'Google Cast';
    }
    if (model.contains('android') || model.contains('android tv')) {
      return 'Android TV';
    }
    if (mfr.contains('microsoft') || model.contains('xbox')) {
      return 'Xbox';
    }
    if (mfr.contains('sony') && (model.contains('playstation') || model.contains('ps'))) {
      return 'PlayStation';
    }
    return 'Smart TV';
  }

  bool _simNames(String a, String b) =>
      a.toLowerCase().replaceAll(' ', '') == b.toLowerCase().replaceAll(' ', '');

  /// Disposes the internal DLNA discovery service.
  void dispose() {
    _dlnaService?.dispose();
    _dlnaService = null;
  }

  /// The shared [MediaCastDlnaApi] instance, available after the first discovery.
  /// Used by [DlnaController] for playback control without re-initializing jUPnP.
  MediaCastDlnaApi? get dlnaApi => _dlnaService?.api;
}
