import 'dart:async';
import 'dart:io';

import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/foundation.dart';

import 'cast_models.dart';
import 'multicast_lock.dart';

/// Discovers DLNA/UPnP MediaRenderer devices via SSDP multicast.
///
/// Uses [DLNAManager] from the `dlna_dart` package which provides:
///
/// 1. **M-SEARCH** — active discovery on 239.255.255.250:1900
/// 2. **NOTIFY listener** — passive discovery (devices that advertise themselves)
/// 3. **Device XML parsing** — fetches and parses device descriptions
///
/// Results are converted to [DiscoveredDevice] models and merged with
/// Chromecast / Jellyfin results in [DeviceDiscovery].
///
/// The [MulticastLockHolder] is acquired on Android to ensure multicast
/// packets reach the WiFi driver.
class DlnaDiscoveryService {
  final Duration timeout;

  DlnaDiscoveryService({this.timeout = const Duration(seconds: 8)});

  DLNAManager? _manager;
  DeviceManager? _deviceManager;

  static const _multicastAddress = '239.255.255.250';
  static const _multicastPort = 1900;

  /// Starts SSDP discovery using [DLNAManager] and returns found devices.
  ///
  /// Runs two discovery paths in parallel:
  /// 1. **dlna_dart** — DLNA/UPnP devices (Samsung, LG, etc.)
  /// 2. **DIAL M-SEARCH** — Fire TV / Firestick devices
  ///
  /// Results are merged and deduplicated by IP.
  Future<List<DiscoveredDevice>> discover() async {
    debugPrint('[DlnaDiscovery] Starting discovery (dlna_dart + DIAL)...');
    await MulticastLockHolder.acquire();
    try {
      final devices = <String, DiscoveredDevice>{};

      // Run both scans in parallel.
      final results = await Future.wait([
        _discoverDlna(devices),
        _discoverDial(devices),
      ]);

      debugPrint('[DlnaDiscovery] dlna_dart=${results[0]} DIAL=${results[1]} total=${devices.length}');
      for (final d in devices.values) {
        debugPrint('[DlnaDiscovery]   "${d.name}" type=${d.type} ip=${d.ip}');
      }

      return devices.values.toList();
    } catch (e) {
      debugPrint('[DlnaDiscovery] Error: $e');
      return [];
    } finally {
      await MulticastLockHolder.release();
    }
  }

  /// DLNA/UPnP discovery via dlna_dart.
  Future<int> _discoverDlna(Map<String, DiscoveredDevice> devices) async {
    try {
      _manager = DLNAManager();
      _deviceManager = await _manager!.start(reusePort: true);

      final subscription = _deviceManager!.devices.stream.listen((map) {
        for (final entry in map.entries) {
          final converted = _convertDevice(entry.value);
          devices.putIfAbsent(converted.ip, () => converted);
        }
      });

      await Future.delayed(timeout);
      await subscription.cancel();
      _manager?.stop();
      _manager = null;
      _deviceManager = null;
      return devices.length;
    } catch (e) {
      debugPrint('[DlnaDiscovery] dlna_dart error: $e');
      return 0;
    }
  }

  /// DIAL discovery for Fire TV / Firestick via M-SEARCH.
  ///
  /// Fire TV devices use Amazon's Fling protocol built on DIAL. They
  /// respond to M-SEARCH with ST: urn:dial-multiscreen-org:service:dial:1
  /// but typically do NOT advertise as UPnP MediaRenderers.
  Future<int> _discoverDial(Map<String, DiscoveredDevice> devices) async {
    int found = 0;
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (_) {
      return 0;
    }

    // Send DIAL M-SEARCH probes.
    const dialTarget = 'urn:dial-multiscreen-org:service:dial:1';
    final mSearch = 'M-SEARCH * HTTP/1.1\r\n'
        'HOST: $_multicastAddress:$_multicastPort\r\n'
        'MAN: "ssdp:discover"\r\n'
        'MX: 2\r\n'
        'ST: $dialTarget\r\n'
        '\r\n';
    for (int i = 0; i < 2; i++) {
      try {
        socket.send(
          mSearch.codeUnits,
          InternetAddress(_multicastAddress),
          _multicastPort,
        );
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Collect responses for the remaining timeout.
    final completer = Completer<void>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) completer.complete();
    });

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = socket.receive();
        if (dg == null) return;
        final response = String.fromCharCodes(dg.data);
        if (!response.contains('200 OK')) return;

        final headers = _parseHeaders(response);
        final loc = headers['location'] ?? '';
        final name = _dialDeviceName(headers);

        if (loc.isNotEmpty && !devices.containsKey(dg.address.address)) {
          found++;
          devices[dg.address.address] = DiscoveredDevice(
            name: name,
            type: 'Fire TV',
            iconType: CastDeviceIcon.tv,
            ip: dg.address.address,
            locationUrl: loc.isNotEmpty ? loc : null,
            serverInfo: 'dial',
          );
          debugPrint('[DlnaDiscovery] DIAL found: "$name" ip=${dg.address.address}');
        }
      }
    }, onDone: () {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;
    timer.cancel();
    try { socket.close(); } catch (_) {}
    return found;
  }

  /// Extracts a human-readable device name from DIAL SSDP headers.
  String _dialDeviceName(Map<String, String> headers) {
    // Try USN first: "uuid:xxx::urn:dial-multiscreen-org:service:dial:1"
    final usn = headers['usn'] ?? '';
    if (usn.isNotEmpty) {
      final parts = usn.split('::');
      if (parts.length >= 2 && parts[0].startsWith('uuid:')) {
        final uuid = parts[0].substring(5);
        if (uuid.isNotEmpty && uuid.length < 30) return uuid;
      }
    }
    // Fall back to server header.
    final server = (headers['server'] ?? '').toLowerCase();
    if (server.contains('fire') || server.contains('aft')) return 'Fire TV';
    if (server.isNotEmpty) return server.split(' ').first;
    return 'Fire TV Device';
  }

  /// Parses HTTP headers from an SSDP response.
  Map<String, String> _parseHeaders(String response) {
    final m = <String, String>{};
    for (final l in response.split('\r\n')) {
      final ci = l.indexOf(':');
      if (ci > 0) {
        m[l.substring(0, ci).trim().toLowerCase()] =
            l.substring(ci + 1).trim();
      }
    }
    return m;
  }

  /// Stops discovery and releases resources.
  Future<void> stop() async {
    _manager?.stop();
    _manager = null;
    _deviceManager = null;
  }

  /// Converts a [DLNADevice] (from dlna_dart) to our [DiscoveredDevice] model.
  DiscoveredDevice _convertDevice(DLNADevice device) {
    final info = device.info;
    final name = info.friendlyName;
    final server = _serverInfoFromDevice(info);

    // Determine device type from manufacturer / model info.
    final type = _deviceType(name, server);

    return DiscoveredDevice(
      name: name,
      type: type,
      iconType: _iconForType(type),
      ip: Uri.tryParse(info.URLBase)?.host ?? '',
      locationUrl: info.URLBase,
      serverInfo: server,
      dlnaDevice: device,
    );
  }

  /// Extracts a server-like identifier from device info for type detection.
  String _serverInfoFromDevice(DeviceInfo info) {
    // Use deviceType as a fallback identifier (e.g.
    // "urn:schemas-upnp-org:device:MediaRenderer:1").
    return info.deviceType.toLowerCase();
  }

  /// Classifies a device by its name and server metadata.
  String _deviceType(String name, String server) {
    final s = server;
    if (s.contains('chromecast') ||
        s.contains('google cast') ||
        name.toLowerCase().contains('chromecast')) {
      return 'Google Cast';
    }
    if (s.contains('amazon') || s.contains('fire') || s.contains('aft')) {
      return 'Fire TV';
    }
    if (s.contains('roku')) {
      return 'Roku';
    }
    if (s.contains('samsung') || s.contains('tizen')) {
      return 'Samsung TV';
    }
    if (s.contains('lg') || s.contains('webos')) {
      return 'LG TV';
    }
    if (s.contains('android')) {
      return 'Android TV';
    }
    if (s.contains('xbox')) {
      return 'Xbox';
    }
    if (s.contains('playstation') || s.contains('ps4') || s.contains('ps5')) {
      return 'PlayStation';
    }
    return 'Smart TV / Cast Device';
  }

  CastDeviceIcon _iconForType(String type) {
    if (type == 'Google Cast') return CastDeviceIcon.cast;
    if (type == 'Xbox' || type == 'PlayStation') return CastDeviceIcon.game;
    return CastDeviceIcon.tv;
  }

  void dispose() {
    stop();
  }
}
