import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:server_core/server_core.dart';
import 'cast_models.dart';
import 'chromecast_discovery.dart';
import 'multicast_lock.dart';

class DeviceDiscovery {
  static const _multicastAddress = '239.255.255.250';
  static const _multicastPort = 1900;
  static const _ssdpTimeout = Duration(seconds: 8);
  static const _mdnsTimeout = Duration(seconds: 8);
  static const _searchTargets = [
    'urn:dial-multiscreen-org:service:dial:1',
    'urn:schemas-upnp-org:device:MediaRenderer:1',
    'urn:schemas-upnp-org:device:MediaServer:1',
    'ssdp:all',
  ];
  final SessionApi _sessionApi;
  DeviceDiscovery(this._sessionApi);

  Future<List<CastTarget>> discover() async {
    debugPrint('[Discovery] Starting device discovery...');
    await MulticastLockHolder.acquire();
    try {
      final results = await Future.wait([
        _discoverSsdpDevices(), _discoverJellyfinDevices(), _discoverChromecastDevices(),
      ]);
      final ssdp = results[0] as List<DiscoveredDevice>;
      final jf = results[1] as List<ServerDevice>;
      final cc = results[2] as List<DiscoveredDevice>;
      debugPrint('[Discovery] Results: SSDP=${ssdp.length} Jellyfin=${jf.length} mDNS/CC=${cc.length}');
      for (final d in ssdp) { debugPrint('[Discovery] SSDP: "${d.name}" type=${d.type} ip=${d.ip}'); }
      for (final d in jf) { debugPrint('[Discovery] Jellyfin: "${d.name}" app=${d.appName}'); }
      for (final d in cc) { debugPrint('[Discovery] Chromecast: "${d.name}" ip=${d.ip} port=${d.port}'); }
      final merged = _mergeDevices(ssdp, jf, cc);
      debugPrint('[Discovery] Total merge targets: ${merged.length}');
      return merged;
    } finally {
      await MulticastLockHolder.release();
    }
  }

  Future<List<DiscoveredDevice>> _discoverSsdpDevices() async {
    final devices = <String, DiscoveredDevice>{};
    RawDatagramSocket? socket;
    try { socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0); } catch (_) { return []; }
    for (final st in _searchTargets) {
      final m = 'M-SEARCH * HTTP/1.1\r\nHOST: $_multicastAddress:$_multicastPort\r\nMAN: "ssdp:discover"\r\nMX: 2\r\nST: $st\r\n\r\n';
      try { socket.send(m.codeUnits, InternetAddress(_multicastAddress), _multicastPort); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200));
    }
    final completer = Completer<void>();
    Timer(_ssdpTimeout, () { if (!completer.isCompleted) completer.complete(); });
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = socket?.receive();
        if (dg != null) {
          final d = _parseSsdpResponse(String.fromCharCodes(dg.data), dg.address.address);
          if (d != null) devices.putIfAbsent(d.ip, () => d);
        }
      }
    }, onDone: () { if (!completer.isCompleted) completer.complete(); });
    await completer.future;
    try { socket.close(); } catch (_) {}
    return devices.values.toList();
  }

  DiscoveredDevice? _parseSsdpResponse(String r, String ip) {
    if (!r.contains('200 OK')) return null;
    final h = _parseHeaders(r);
    final loc = h['location'] ?? '', srv = (h['server'] ?? '').toLowerCase(), usn = h['usn'] ?? '', st = h['st'] ?? '';
    String t; CastDeviceIcon i;
    if (st.contains('dial') || srv.contains('chromecast') || srv.contains('google cast')) { t = 'Google Cast'; i = CastDeviceIcon.cast; }
    else if (srv.contains('amazon') || srv.contains('fire') || srv.contains('aft')) { t = 'Fire TV'; i = CastDeviceIcon.tv; }
    else if (srv.contains('roku')) { t = 'Roku'; i = CastDeviceIcon.tv; }
    else if (srv.contains('fire') || srv.contains('amazon')) { t = 'Fire TV'; i = CastDeviceIcon.tv; }
    else if (srv.contains('samsung') || srv.contains('tizen')) { t = 'Samsung TV'; i = CastDeviceIcon.tv; }
    else if (srv.contains('lg') || srv.contains('webos')) { t = 'LG TV'; i = CastDeviceIcon.tv; }
    else if (srv.contains('android')) { t = 'Android TV'; i = CastDeviceIcon.tv; }
    else if (srv.contains('xbox')) { t = 'Xbox'; i = CastDeviceIcon.game; }
    else if (srv.contains('playstation') || srv.contains('ps4') || srv.contains('ps5')) { t = 'PlayStation'; i = CastDeviceIcon.game; }
    else { t = 'Smart TV / Cast Device'; i = CastDeviceIcon.tv; }
    return DiscoveredDevice(name: _dn(srv, usn, ip), type: t, iconType: i, ip: ip, locationUrl: loc.isNotEmpty ? loc : null, serverInfo: srv.isNotEmpty ? srv : null, isChromecast: t == 'Google Cast');
  }

  Map<String, String> _parseHeaders(String r) {
    final m = <String, String>{};
    for (final l in r.split('\r\n')) { final ci = l.indexOf(':'); if (ci > 0) m[l.substring(0, ci).trim().toLowerCase()] = l.substring(ci + 1).trim(); }
    return m;
  }

  String _dn(String sr, String us, String ip) {
    if (us.isNotEmpty) { final ps = us.split('::'); if (ps.length >= 2) { final u = ps[0].replaceAll('uuid:', ''); if (u.isNotEmpty && u.length < 30) return u; } }
    if (sr.isNotEmpty) { final p = sr.split(' ').first.split('/').first; if (p.isNotEmpty && p.length > 2) return p; }
    return 'Device ($ip)';
  }

  Future<List<DiscoveredDevice>> _discoverChromecastDevices() async {
    try {
      final cc = await ChromecastDiscovery.discover().timeout(_mdnsTimeout);
      return cc.map((c) => DiscoveredDevice(name: c.name, type: 'Google Cast', iconType: CastDeviceIcon.cast, ip: c.host, port: c.port, isChromecast: true)).toList();
    } catch (_) { return []; }
  }

  Future<List<ServerDevice>> _discoverJellyfinDevices() async {
    try { final d = await _sessionApi.getDevices(); return d.where((x) => _isCastDevice(x)).toList(); } catch (_) { return []; }
  }

  bool _isCastDevice(ServerDevice d) {
    final a = d.appName?.toLowerCase() ?? '', n = d.name.toLowerCase();
    // Exclude: web/mobile clients, and ourselves (Yuuna/jidoujisho).
    for (final w in ['web','browser','mobile','html','desktop','phone','tablet','yuuna','jidoujisho']) { if (a.contains(w)||n.contains(w)) return false; }
    for (final p in ['chromecast','android tv','google tv','fire tv','firestick','amazon','samsung','tizen','lg tv','webos','roku','apple tv','shield','xbox','playstation','ps4','ps5','tv','television','cast','dlna','raspberry','kodi','plex']) { if (a.contains(p)||n.contains(p)) return true; }
    return a.isNotEmpty && a != 'unknown' && a != 'android' && a != 'ios';
  }

  List<CastTarget> _mergeDevices(List<DiscoveredDevice> ss, List<ServerDevice> jf, List<DiscoveredDevice> cc) {
    final tg = <CastTarget>[], sn = <String>{};
    for (final d in cc) { final k = d.name.toLowerCase(); if (!sn.contains(k)) { sn.add(k); tg.add(CastTarget(name: d.name, type: d.type, icon: d.iconType, ssdpDevice: d)); } }
    for (final d in jf) { final k = d.name.toLowerCase(); if (!sn.contains(k)) { sn.add(k); final ms = ss.cast<DiscoveredDevice?>().firstWhere((s) => s!.ip == d.id || _sim(s.name, d.name), orElse: () => null); tg.add(CastTarget(name: d.name, type: d.appName ?? 'Jellyfin Client', icon: CastDeviceIcon.tv, jellyfinDevice: d, ssdpDevice: ms)); } }
    for (final d in ss) { final k = d.name.toLowerCase(); if (!sn.contains(k)) { sn.add(k); tg.add(CastTarget(name: d.name, type: d.type, icon: d.iconType, ssdpDevice: d)); } }
    return tg;
  }

  bool _sim(String a, String b) => a.toLowerCase().replaceAll(' ', '') == b.toLowerCase().replaceAll(' ', '');
}
