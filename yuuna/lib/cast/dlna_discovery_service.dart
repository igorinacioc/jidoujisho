import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'cast_models.dart';
import 'multicast_lock.dart';

/// Discovers DLNA/UPnP MediaRenderer devices via SSDP multicast.
///
/// Sends M-SEARCH requests on 239.255.255.250:1900 for known search targets
/// and collects responses into [DiscoveredDevice] models. Uses [MulticastLockHolder]
/// on Android to ensure multicast packets reach the WiFi driver.
///
/// Replaces the old inline SSDP code in [DeviceDiscovery] with a dedicated,
/// testable service — ready to swap for jUPnP (via media_cast_dlna) when
/// Flutter is upgraded beyond 3.13.5.
class DlnaDiscoveryService {
  static const _multicastAddress = '239.255.255.250';
  static const _multicastPort = 1900;
  static const _searchTargets = [
    'urn:dial-multiscreen-org:service:dial:1',
    'urn:schemas-upnp-org:device:MediaRenderer:1',
    'urn:schemas-upnp-org:device:MediaServer:1',
    'ssdp:all',
  ];

  final Duration timeout;

  DlnaDiscoveryService({this.timeout = const Duration(seconds: 8)});

  /// Starts SSDP discovery and returns found [DiscoveredDevice]s.
  Future<List<DiscoveredDevice>> discover() async {
    debugPrint('[DlnaDiscovery] Starting SSDP discovery...');
    await MulticastLockHolder.acquire();
    try {
      final devices = await _discoverSsdp();
      debugPrint('[DlnaDiscovery] SSDP scan complete: ${devices.length} devices');
      for (final d in devices) {
        debugPrint('[DlnaDiscovery]   "${d.name}" type=${d.type} ip=${d.ip}');
      }
      return devices;
    } finally {
      await MulticastLockHolder.release();
    }
  }

  Future<List<DiscoveredDevice>> _discoverSsdp() async {
    final devices = <String, DiscoveredDevice>{};
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (_) {
      return [];
    }

    for (final st in _searchTargets) {
      final m = 'M-SEARCH * HTTP/1.1\r\n'
          'HOST: $_multicastAddress:$_multicastPort\r\n'
          'MAN: "ssdp:discover"\r\n'
          'MX: 2\r\n'
          'ST: $st\r\n'
          '\r\n';
      try {
        socket.send(m.codeUnits, InternetAddress(_multicastAddress), _multicastPort);
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final completer = Completer<void>();
    Timer(timeout, () {
      if (!completer.isCompleted) completer.complete();
    });

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = socket?.receive();
        if (dg != null) {
          final d = _parseSsdpResponse(
            String.fromCharCodes(dg.data),
            dg.address.address,
          );
          if (d != null) devices.putIfAbsent(d.ip, () => d);
        }
      }
    }, onDone: () {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;
    try { socket.close(); } catch (_) {}
    return devices.values.toList();
  }

  DiscoveredDevice? _parseSsdpResponse(String response, String ip) {
    if (!response.contains('200 OK')) return null;
    final headers = _parseHeaders(response);
    final loc = headers['location'] ?? '';
    final srv = (headers['server'] ?? '').toLowerCase();
    final usn = headers['usn'] ?? '';
    final st = headers['st'] ?? '';

    String type;
    CastDeviceIcon icon;
    if (st.contains('dial') || srv.contains('chromecast') || srv.contains('google cast')) {
      type = 'Google Cast';
      icon = CastDeviceIcon.cast;
    } else if (srv.contains('amazon') || srv.contains('fire') || srv.contains('aft')) {
      type = 'Fire TV';
      icon = CastDeviceIcon.tv;
    } else if (srv.contains('roku')) {
      type = 'Roku';
      icon = CastDeviceIcon.tv;
    } else if (srv.contains('samsung') || srv.contains('tizen')) {
      type = 'Samsung TV';
      icon = CastDeviceIcon.tv;
    } else if (srv.contains('lg') || srv.contains('webos')) {
      type = 'LG TV';
      icon = CastDeviceIcon.tv;
    } else if (srv.contains('android')) {
      type = 'Android TV';
      icon = CastDeviceIcon.tv;
    } else if (srv.contains('xbox')) {
      type = 'Xbox';
      icon = CastDeviceIcon.game;
    } else if (srv.contains('playstation') || srv.contains('ps4') || srv.contains('ps5')) {
      type = 'PlayStation';
      icon = CastDeviceIcon.game;
    } else {
      type = 'Smart TV / Cast Device';
      icon = CastDeviceIcon.tv;
    }

    return DiscoveredDevice(
      name: _deviceName(srv, usn, ip),
      type: type,
      iconType: icon,
      ip: ip,
      locationUrl: loc.isNotEmpty ? loc : null,
      serverInfo: srv.isNotEmpty ? srv : null,
      isChromecast: type == 'Google Cast',
    );
  }

  Map<String, String> _parseHeaders(String response) {
    final m = <String, String>{};
    for (final l in response.split('\r\n')) {
      final ci = l.indexOf(':');
      if (ci > 0) {
        m[l.substring(0, ci).trim().toLowerCase()] = l.substring(ci + 1).trim();
      }
    }
    return m;
  }

  String _deviceName(String server, String usn, String ip) {
    if (usn.isNotEmpty) {
      final ps = usn.split('::');
      if (ps.length >= 2) {
        final u = ps[0].replaceAll('uuid:', '');
        if (u.isNotEmpty && u.length < 30) return u;
      }
    }
    if (server.isNotEmpty) {
      final p = server.split(' ').first.split('/').first;
      if (p.isNotEmpty && p.length > 2) return p;
    }
    return 'Device ($ip)';
  }

  void dispose() {}
}
