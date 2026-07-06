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
  static const _mdnsTimeout = Duration(seconds: 4);
  static const _ssdpTimeout = Duration(seconds: 4);
  static const _jellyfinTimeout = Duration(seconds: 5);

  final SessionApi _sessionApi;

  DeviceDiscovery(this._sessionApi);

  // ─── Cached results ─────────────────────────────────────────────────────

  /// Last discovered devices — shown instantly while refreshing.
  static List<CastTarget>? _cached;

  /// Timestamp of the last successful discovery.
  static DateTime? _lastDiscoverTime;

  /// Cache TTL: reuse cache for 30s before doing a full scan.
  static const _cacheTtl = Duration(seconds: 30);

  /// Returns cached devices if they're still fresh.
  static List<CastTarget>? get cachedDevices {
    if (_cached == null || _lastDiscoverTime == null) return null;
    if (DateTime.now().difference(_lastDiscoverTime!) > _cacheTtl) return null;
    return _cached;
  }

  /// Clears the device cache so the next discovery does a fresh scan.
  static void clearCache() {
    _cached = null;
    _lastDiscoverTime = null;
  }

  // ─── Legacy batch API ──────────────────────────────────────────────────

  /// Discovers all available cast targets across DLNA, Chromecast, and Jellyfin.
  ///
  /// Prefer [discoverIncremental] for a responsive UI — it shows devices
  /// as they're found instead of blocking until all methods complete.
  Future<List<CastTarget>> discover() async {
    final results = <CastTarget>[];
    await for (final batch in discoverIncremental()) {
      results.clear();
      results.addAll(batch);
    }
    return results;
  }

  // ─── Incremental discovery (streaming) ─────────────────────────────────

  /// Discovers devices incrementally, emitting the cumulative list as soon
  /// as any discovery method finds new devices.
  ///
  /// Three methods run concurrently (DLNA SSDP, Chromecast mDNS, Jellyfin API).
  /// The stream yields every ~500ms while devices are still being discovered.
  ///
  /// Like YouTube's Cast dialog:
  /// - Opens instantly (cached devices emitted first)
  /// - Devices appear progressively
  /// - No blocking — user can pick a device as soon as it appears
  Stream<List<CastTarget>> discoverIncremental() async* {
    debugPrint('[Discovery] Starting incremental device discovery...');

    // Emit cached devices immediately if available (instant first paint).
    final cached = cachedDevices;
    if (cached != null && cached.isNotEmpty) {
      debugPrint('[Discovery] Emitting ${cached.length} cached devices instantly');
      yield cached;
    }

    final dlnaService = DlnaDiscoveryService(timeout: _ssdpTimeout);

    // Per-method result accumulators.
    final dlna = <DiscoveredDevice>[];
    final cc = <DiscoveredDevice>[];
    final jf = <ServerDevice>[];

    // Completion flags — set by .then() callbacks.
    bool dlnaDone = false;
    bool ccDone = false;
    bool jfDone = false;

    // Fire all 3 discovery methods concurrently.
    // Each one populates its accumulator when done.
    dlnaService.discover().then((d) {
      dlna.addAll(d);
      dlnaDone = true;
      debugPrint('[Discovery] DLNA done: ${d.length} devices');
    });

    _discoverChromecastDevices().then((d) {
      cc.addAll(d);
      ccDone = true;
      debugPrint('[Discovery] Chromecast done: ${d.length} devices');
    });

    _discoverJellyfinDevices().then((d) {
      jf.addAll(d);
      jfDone = true;
      debugPrint('[Discovery] Jellyfin done: ${d.length} devices');
    });

    // Poll every 500ms and emit whenever new devices are found.
    int lastTotal = cached?.length ?? 0;
    final startTime = DateTime.now();
    const maxWait = Duration(seconds: 10);

    while (!(dlnaDone && ccDone && jfDone)) {
      await Future.delayed(const Duration(milliseconds: 500));

      final currentTotal = dlna.length + cc.length + jf.length;
      final elapsed = DateTime.now().difference(startTime);

      if (currentTotal > lastTotal) {
        lastTotal = currentTotal;
        final merged = _mergeDevices(dlna, jf, cc);
        _updateCache(merged);
        debugPrint('[Discovery] → ${merged.length} devices so far (DLNA:${dlnaDone} CC:${ccDone} JF:${jfDone})');
        yield merged;
      }

      // Hard timeout — stop waiting for stragglers.
      if (elapsed > maxWait) {
        debugPrint('[Discovery] Max wait reached, stopping early');
        break;
      }
    }

    // Final emit with whatever we have.
    final finalMerged = _mergeDevices(dlna, jf, cc);
    _updateCache(finalMerged);
    debugPrint('[Discovery] Final: ${finalMerged.length} devices');
    yield finalMerged;
  }

  void _updateCache(List<CastTarget> devices) {
    _cached = devices;
    _lastDiscoverTime = DateTime.now();
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
      final d = await _sessionApi.getDevices().timeout(_jellyfinTimeout);
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
