import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_cast_dlna/media_cast_dlna.dart';

/// Wraps [MediaCastDlnaApi] for DLNA device discovery via jUPnP.
///
/// Exposes the underlying [api] so that [DlnaController] can reuse the same
/// UPnP stack instance (already initialized) for playback control.
///
/// Replaces the old SSDP raw-socket discovery with event-driven jUPnP
/// discovery that finds a much wider range of devices (Samsung, LG,
/// Fire TV, Roku, and any UPnP MediaRenderer).
///
/// Usage:
/// ```dart
/// final service = DlnaDiscoveryService();
/// await service.initialize();
/// final devices = await service.discover(timeout: Duration(seconds: 8));
/// // ... use devices ...
/// await service.stop();
/// ```
class DlnaDiscoveryService {
  final MediaCastDlnaApi _api = MediaCastDlnaApi();
  MediaCastDlnaDiscoveryEvents? _events;
  bool _initialized = false;
  bool _discovering = false;

  final List<DlnaDevice> _devices = [];
  final _controller = StreamController<List<DlnaDevice>>.broadcast();

  /// Stream of discovered DLNA devices, emitted whenever the device list changes.
  Stream<List<DlnaDevice>> get devices => _controller.stream;

  /// The current list of discovered DLNA renderers.
  List<DlnaDevice> get currentDevices => List.unmodifiable(_devices);

  /// The underlying [MediaCastDlnaApi] instance, shared for playback control.
  MediaCastDlnaApi get api => _api;

  /// Whether the UPnP service has been initialized.
  bool get isInitialized => _initialized;

  /// Initializes the jUPnP Android service. Must be called once before discovery.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _api.initializeUpnpService();
      _initialized = true;
      debugPrint('[DlnaDiscovery] UPnP service initialized');
    } catch (e) {
      debugPrint('[DlnaDiscovery] Failed to initialize UPnP service: $e');
    }
  }

  /// Starts event-driven discovery and collects devices for [timeout].
  ///
  /// Returns all MediaRenderer devices found during the discovery window.
  /// Subscribe to [devices] stream for real-time updates.
  Future<List<DlnaDevice>> discover({Duration timeout = const Duration(seconds: 8)}) async {
    if (!_initialized) {
      debugPrint('[DlnaDiscovery] Not initialized — call initialize() first');
      return [];
    }

    _devices.clear();
    _discovering = true;

    // Set up event listeners.
    _events?.dispose();
    _events = MediaCastDlnaDiscoveryEvents();

    _events!.onDeviceFound.listen((device) {
      if (!device.isRenderer) return;
      final idx = _devices.indexWhere((d) => d.udn.value == device.udn.value);
      if (idx >= 0) {
        _devices[idx] = device; // Update.
      } else {
        _devices.add(device);
        debugPrint('[DlnaDiscovery] Found: "${device.friendlyName}" [${device.manufacturerDetails.manufacturer}]');
      }
      _controller.add(List.unmodifiable(_devices));
    });

    _events!.onDeviceLost.listen((udn) {
      _devices.removeWhere((d) => d.udn.value == udn.value);
      _controller.add(List.unmodifiable(_devices));
    });

    try {
      await _api.startDiscovery(
        DiscoveryOptions(
          timeout: DiscoveryTimeout(seconds: timeout.inSeconds),
          searchTarget: SearchTarget(target: 'urn:schemas-upnp-org:device:MediaRenderer:1'),
        ),
      );

      // Wait for the discovery timeout to elapse.
      await Future.delayed(timeout);

      // Stop the active scan.
      await _api.stopDiscovery();
    } catch (e) {
      debugPrint('[DlnaDiscovery] Discovery error: $e');
    }

    _discovering = false;
    debugPrint('[DlnaDiscovery] Scan complete: ${_devices.length} renderers found');

    // Filter to only renderers.
    final renderers = _devices.where((d) => d.isRenderer).toList();
    return renderers;
  }

  /// Stops discovery and cleans up event listeners.
  Future<void> stop() async {
    if (_discovering) {
      try { await _api.stopDiscovery(); } catch (_) {}
      _discovering = false;
    }
    await _events?.dispose();
    _events = null;
  }

  /// Disposes all resources.
  void dispose() {
    stop();
    _controller.close();
  }
}
