import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:server_core/server_core.dart';

import 'cast_models.dart';
import 'chromecast_discovery.dart';
import 'dlna_discovery_service.dart';

/// Discovers cast targets on the local network using three independent methods:
///
/// 1. **DLNA (SSDP)** — finds UPnP MediaRenderers (Samsung, LG, Fire TV, etc.).
/// 2. **Chromecast mDNS** — finds Google Cast devices via `_googlecast._tcp.local`.
/// 3. **Jellyfin API** — lists Jellyfin-registered clients (Android TV, etc.).
///
/// Results are merged into a unified [CastTarget] list for the picker UI.
///
/// Note: The DLNA discovery uses our own SSDP implementation today, but
/// [DlnaDiscoveryService] is designed to be swappable for `media_cast_dlna`
/// (jUPnP) when the project upgrades beyond Flutter 3.13.5.
class DeviceDiscovery {
  static const _mdnsTimeout = Duration(seconds: 8);

  final SessionApi _sessionApi;

  DeviceDiscovery(this._sessionApi);

  /// Discovers all available cast targets across DLNA, Chromecast, and Jellyfin.
  Future<List<CastTarget>> discover() async {
    debugPrint('[Discovery] Starting device discovery...');

    final dlnaService = DlnaDiscoveryService();

    final results = await Future.wait([
      dlnaService.discover(),
      _discoverChromecastDevices(),
      _discoverJellyfinDevices(),
    ]);

    final dlna = results[0] as List<DiscoveredDevice>;
    final cc = results[1] as List<DiscoveredDevice>;
    final jf = results[2] as List<ServerDevice>;

    debugPrint('[Discovery] Results: SSDP=${dlna.length} Chromecast=${cc.length} Jellyfin=${jf.length}');
    for (final d in dlna) {
      debugPrint('[Discovery] SSDP: "${d.name}" type=${d.type} ip=${d.ip}');
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
    List<DiscoveredDevice> ssdp,
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

    // 2. Jellyfin devices — try to match with SSDP devices.
    for (final d in jf) {
      final k = d.name.toLowerCase();
      if (sn.contains(k)) continue;
      sn.add(k);

      // Match Jellyfin device with an SSDP device by name/IP.
      DiscoveredDevice? matchedSsdp;
      for (final sd in ssdp) {
        if (_simNames(sd.name, d.name) || sd.ip == d.id) {
          matchedSsdp = sd;
          break;
        }
      }

      tg.add(CastTarget(
        name: d.name,
        type: d.appName ?? 'Jellyfin Client',
        icon: CastDeviceIcon.tv,
        jellyfinDevice: d,
        dlnaDevice: matchedSsdp,
        ssdpDevice: matchedSsdp, // For backward compat.
      ));
    }

    // 3. Remaining SSDP/DLNA devices (not matched to Jellyfin or Chromecast).
    for (final d in ssdp) {
      final k = d.name.toLowerCase();
      if (sn.contains(k)) continue;
      sn.add(k);

      tg.add(CastTarget(
        name: d.name,
        type: d.type,
        icon: d.iconType,
        dlnaDevice: d,
        ssdpDevice: d,
      ));
    }

    return tg;
  }

  bool _simNames(String a, String b) =>
      a.toLowerCase().replaceAll(' ', '') == b.toLowerCase().replaceAll(' ', '');
}
