import 'dart:async';

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

  /// Starts SSDP discovery using [DLNAManager] and returns found devices.
  ///
  /// The [DLNAManager] sends periodic M-SEARCH probes AND listens for NOTIFY
  /// announcements — covering devices that don't respond to M-SEARCH.
  Future<List<DiscoveredDevice>> discover() async {
    debugPrint('[DlnaDiscovery] Starting SSDP discovery via dlna_dart...');
    await MulticastLockHolder.acquire();
    try {
      _manager = DLNAManager();
      _deviceManager = await _manager!.start(reusePort: true);

      final devices = <String, DiscoveredDevice>{};

      final subscription = _deviceManager!.devices.stream.listen((map) {
        for (final entry in map.entries) {
          final dlnaDevice = entry.value;
          final converted = _convertDevice(dlnaDevice);
          devices.putIfAbsent(converted.ip, () => converted);
        }
      });

      // Wait for the discovery timeout, then collect results.
      await Future.delayed(timeout);

      await subscription.cancel();
      await stop();

      debugPrint(
        '[DlnaDiscovery] SSDP scan complete: ${devices.length} devices',
      );
      for (final d in devices.values) {
        debugPrint(
          '[DlnaDiscovery]   "${d.name}" type=${d.type} ip=${d.ip}',
        );
      }

      return devices.values.toList();
    } catch (e) {
      debugPrint('[DlnaDiscovery] Error: $e');
      await stop();
      return [];
    } finally {
      await MulticastLockHolder.release();
    }
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
