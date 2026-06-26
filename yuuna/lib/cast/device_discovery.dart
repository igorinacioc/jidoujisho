import 'dart:async';
import 'dart:io';

import 'package:server_core/server_core.dart';

import 'cast_models.dart';

/// Discovers cast-capable devices on the local network.
///
/// Combines two discovery methods:
/// 1. **SSDP/UPnP multicast** — finds TVs, Chromecasts, and other DLNA renderers.
/// 2. **Jellyfin Device API** — finds devices registered on the Jellyfin server.
///
/// Results are merged and deduplicated into a single list of [CastTarget]s.
class DeviceDiscovery {
  static const _multicastAddress = '239.255.255.250';
  static const _multicastPort = 1900;
  static const _ssdpTimeout = Duration(seconds: 4);

  static const _searchTargets = [
    'urn:dial-multiscreen-org:service:dial:1',
    'urn:schemas-upnp-org:device:MediaRenderer:1',
  ];

  final SessionApi _sessionApi;

  DeviceDiscovery(this._sessionApi);

  /// Discovers all available cast targets.
  ///
  /// Runs SSDP and Jellyfin device listing in parallel.
  Future<List<CastTarget>> discover() async {
    final results = await Future.wait([
      _discoverSsdpDevices(),
      _discoverJellyfinDevices(),
    ]);

    final ssdpDevices = results[0] as List<DiscoveredDevice>;
    final jellyfinDevices = results[1] as List<ServerDevice>;

    return _mergeDevices(ssdpDevices, jellyfinDevices);
  }

  // ─── SSDP Discovery ────────────────────────────────────────────────────

  Future<List<DiscoveredDevice>> _discoverSsdpDevices() async {
    final devices = <String, DiscoveredDevice>{};

    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (_) {
      return [];
    }

    // Send M-SEARCH for each target.
    for (final st in _searchTargets) {
      final message = 'M-SEARCH * HTTP/1.1\r\n'
          'HOST: $_multicastAddress:$_multicastPort\r\n'
          'MAN: "ssdp:discover"\r\n'
          'MX: 2\r\n'
          'ST: $st\r\n'
          '\r\n';
      try {
        socket.send(
          message.codeUnits,
          InternetAddress(_multicastAddress),
          _multicastPort,
        );
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final completer = Completer<void>();
    Timer(_ssdpTimeout, () {
      if (!completer.isCompleted) completer.complete();
    });

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket?.receive();
        if (datagram != null) {
          final data = String.fromCharCodes(datagram.data);
          final device = _parseSsdpResponse(data, datagram.address.address);
          if (device != null) {
            devices.putIfAbsent(device.ip, () => device);
          }
        }
      }
    }, onDone: () {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;
    try {
      socket.close();
    } catch (_) {}

    return devices.values.toList();
  }

  DiscoveredDevice? _parseSsdpResponse(String response, String ip) {
    if (!response.contains('200 OK')) return null;

    final headers = _parseHeaders(response);
    final location = headers['location'] ?? '';
    final server = headers['server'] ?? '';
    final usn = headers['usn'] ?? '';
    final st = headers['st'] ?? '';

    final srv = server.toLowerCase();
    String type;
    CastDeviceIcon icon;

    if (st.contains('dial') || srv.contains('chromecast')) {
      type = 'Google Cast';
      icon = CastDeviceIcon.cast;
    } else if (srv.contains('roku')) {
      type = 'Roku';
      icon = CastDeviceIcon.tv;
    } else if (srv.contains('fire') || srv.contains('amazon')) {
      type = 'Fire TV';
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

    final name = _extractDeviceName(server, usn, ip);

    return DiscoveredDevice(
      name: name,
      type: type,
      iconType: icon,
      ip: ip,
      locationUrl: location.isNotEmpty ? location : null,
      serverInfo: server.isNotEmpty ? server : null,
    );
  }

  Map<String, String> _parseHeaders(String response) {
    final headers = <String, String>{};
    for (final line in response.split('\r\n')) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim().toLowerCase();
        final value = line.substring(colonIndex + 1).trim();
        headers[key] = value;
      }
    }
    return headers;
  }

  String _extractDeviceName(String server, String usn, String ip) {
    if (usn.isNotEmpty) {
      final parts = usn.split('::');
      if (parts.length >= 2) {
        final uuidPart = parts[0].replaceAll('uuid:', '');
        if (uuidPart.isNotEmpty && uuidPart.length < 30) return uuidPart;
      }
    }
    if (server.isNotEmpty) {
      final platformPart = server.split(' ').first;
      final platform = platformPart.split('/').first;
      if (platform.isNotEmpty && platform.length > 2) return platform;
    }
    return 'Device ($ip)';
  }

  // ─── Jellyfin Device Discovery ─────────────────────────────────────────

  Future<List<ServerDevice>> _discoverJellyfinDevices() async {
    try {
      final devices = await _sessionApi.getDevices();
      return devices.where((d) => _isCastDevice(d)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Heuristic to determine if a Jellyfin-registered device is a cast target.
  ///
  /// Filters out web browsers, mobile apps, and desktop clients.
  /// Returns true for TVs, streaming sticks, game consoles, etc.
  bool _isCastDevice(ServerDevice device) {
    final app = device.appName?.toLowerCase() ?? '';
    final devName = device.name.toLowerCase();

    // Exclude non-cast clients.
    const exclude = ['web', 'browser', 'mobile', 'html', 'desktop', 'phone', 'tablet'];
    for (final term in exclude) {
      if (app.contains(term)) return false;
      if (devName.contains(term)) return false;
    }

    // Known TV/streaming/gaming platforms.
    const platforms = [
      'chromecast', 'android tv', 'google tv',
      'fire tv', 'firestick', 'fire stick', 'amazon',
      'samsung', 'tizen', 'lg tv', 'webos', 'lg ',
      'roku', 'apple tv', 'nvidia shield', 'shield',
      'xbox', 'playstation', 'ps4', 'ps5',
      'tv', 'television', 'cast', 'dlna',
      'raspberry', 'kodi', 'plex',
    ];
    for (final platform in platforms) {
      if (app.contains(platform) || devName.contains(platform)) return true;
    }

    // Any non-generic, non-excluded app name is likely a TV client.
    if (app.isNotEmpty && app != 'unknown' && app != 'android' && app != 'ios') {
      return true;
    }

    return false;
  }

  // ─── Merge & Deduplicate ───────────────────────────────────────────────

  /// Merges SSDP and Jellyfin devices, deduplicating by IP/name.
  List<CastTarget> _mergeDevices(
    List<DiscoveredDevice> ssdpDevices,
    List<ServerDevice> jellyfinDevices,
  ) {
    final targets = <CastTarget>[];
    final seenNames = <String>{};

    // Add Jellyfin devices first (they have richer metadata).
    for (final device in jellyfinDevices) {
      final key = device.name.toLowerCase();
      if (seenNames.contains(key)) continue;
      seenNames.add(key);

      // Try to match with an SSDP device on the same network.
      final matchingSsdp = ssdpDevices.cast<DiscoveredDevice?>().firstWhere(
            (d) => d!.ip == device.id || _namesSimilar(d.name, device.name),
            orElse: () => null,
          );

      targets.add(CastTarget(
        name: device.name,
        type: device.appName ?? 'Jellyfin Client',
        icon: CastDeviceIcon.tv,
        jellyfinDevice: device,
        ssdpDevice: matchingSsdp,
      ));
    }

    // Add remaining SSDP devices.
    for (final device in ssdpDevices) {
      final key = device.name.toLowerCase();
      if (seenNames.contains(key)) continue;
      seenNames.add(key);

      targets.add(CastTarget(
        name: device.name,
        type: device.type,
        icon: device.iconType,
        ssdpDevice: device,
      ));
    }

    return targets;
  }

  bool _namesSimilar(String a, String b) {
    return a.toLowerCase().replaceAll(' ', '') == b.toLowerCase().replaceAll(' ', '');
  }
}
