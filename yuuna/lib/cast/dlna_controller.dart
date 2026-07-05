import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'cast_models.dart';
import 'dlna_device_wrapper.dart';

/// Controls a DLNA/UPnP cast session via SOAP/UPnP.
///
/// Sends a stream URL to a TV/renderer via UPnP AVTransport,
/// then polls the playback position for subtitle synchronization.
///
/// Two construction paths:
///
/// 1. **Preferred**: [DlnaController.fromDlnaDevice] — uses a pre-parsed
///    [DLNADevice] from `dlna_dart` discovery. Skips the XML fetch and
///    provides volume/mute/next/prev via [DlnaDeviceWrapper].
///
/// 2. **Fallback**: [DlnaController.connect] — fetches the device description
///    XML from `deviceLocationUrl` and uses raw SOAP. Kept for backward
///    compatibility with devices discovered outside dlna_dart.
///
/// Uses CDATA in SOAP envelopes to prevent XML entity corruption of URLs
/// (the `&` → `&amp;` bug that broke query params on many TVs).
///
/// Used by [MiningModePage] to keep subtitles in sync with the TV.
class DlnaController extends CastSession {
  final String _controlUrl;
  final String _deviceName;
  final DlnaDeviceWrapper? _wrapper;

  DlnaController({
    required String controlUrl,
    required String deviceName,
    DlnaDeviceWrapper? wrapper,
  })  : _controlUrl = controlUrl,
        _deviceName = deviceName,
        _wrapper = wrapper;

  // ─── State ───────────────────────────────────────────────────────────────

  CastSessionState _state = CastSessionState.connecting;
  CastPosition _position = CastPosition.empty;
  Timer? _pollTimer;
  int _consecutiveFailures = 0;
  static const int _maxFailures = 5;
  static const Duration _pollInterval = Duration(milliseconds: 500);

  // ─── Getters ─────────────────────────────────────────────────────────────

  CastSessionState get state => _state;
  CastPosition get position => _position;
  String get deviceName => _deviceName;
  String get controlUrl => _controlUrl;
  bool get isActive =>
      _state == CastSessionState.playing || _state == CastSessionState.paused;

  /// The sync-adjusted position for subtitle matching.
  Duration get syncedPosition => _position.syncedPosition;

  // ─── Construction — Preferred: from DLNADevice ───────────────────────────

  /// Creates a controller from a pre-parsed [DLNADevice].
  ///
  /// Uses [DlnaDeviceWrapper] for all SOAP commands, which provides
  /// CDATA-safe URL handling, volume/mute, next/prev, and transport info.
  static Future<DlnaController?> fromDlnaDevice({
    required String streamUrl,
    required DLNADevice dlnaDevice,
    String? deviceName,
  }) async {
    try {
      final wrapper = DlnaDeviceWrapper(dlnaDevice);
      final info = dlnaDevice.info;

      // Get the AVTransport control URL from the pre-parsed device info.
      String controlUrl;
      try {
        controlUrl = dlnaDevice.controlURL('AVTransport');
      } catch (_) {
        return null;
      }

      // Set the media URI (uses CDATA internally).
      await wrapper.setUrl(streamUrl, title: info.friendlyName);

      // Start playback.
      await wrapper.play();

      final controller = DlnaController(
        controlUrl: controlUrl,
        deviceName: deviceName ?? info.friendlyName,
        wrapper: wrapper,
      );
      controller._state = CastSessionState.playing;
      controller.startPolling();
      return controller;
    } catch (e) {
      debugPrint('[DlnaController.fromDlnaDevice] Error: $e');
      return null;
    }
  }

  // ─── Construction — Fallback: manual XML fetch ───────────────────────────

  /// Sends a stream URL to the DLNA renderer and starts playback.
  ///
  /// Fetches the device description XML from [deviceLocationUrl] to find
  /// the AVTransport control URL. Prefer [fromDlnaDevice] when a pre-parsed
  /// [DLNADevice] is available.
  static Future<DlnaController?> connect({
    required String streamUrl,
    required String deviceLocationUrl,
    String? deviceName,
    DLNADevice? dlnaDevice,
  }) async {
    // If we have a pre-parsed DLNADevice, use the preferred path.
    if (dlnaDevice != null) {
      return fromDlnaDevice(
        streamUrl: streamUrl,
        dlnaDevice: dlnaDevice,
        deviceName: deviceName,
      );
    }

    // Fallback: fetch and parse device description XML manually.
    try {
      final descResponse = await http
          .get(Uri.parse(deviceLocationUrl))
          .timeout(const Duration(seconds: 5));
      if (descResponse.statusCode != 200) return null;

      final doc = html_parser.parse(descResponse.body);
      String? controlUrl;
      final services = doc.getElementsByTagName('service');
      for (final svc in services) {
        final serviceType =
            svc.getElementsByTagName('servicetype').firstOrNull?.text ?? '';
        if (serviceType.toLowerCase().contains('avtransport')) {
          final relative =
              svc.getElementsByTagName('controlurl').firstOrNull?.text ?? '';
          final base = Uri.parse(deviceLocationUrl);
          controlUrl = base.resolve(relative).toString();
          break;
        }
      }
      if (controlUrl == null) return null;

      // SetAVTransportURI with CDATA.
      final setUriBody = _buildSoapEnvelope(
        'SetAVTransportURI',
        '<InstanceID>0</InstanceID>'
            '<CurrentURI><![CDATA[$streamUrl]]></CurrentURI>'
            '<CurrentURIMetaData></CurrentURIMetaData>',
      );
      final uriResponse = await http
          .post(
            Uri.parse(controlUrl),
            headers: {
              'Content-Type': 'text/xml; charset="utf-8"',
              'SOAPACTION':
                  '"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI"',
            },
            body: setUriBody,
          )
          .timeout(const Duration(seconds: 5));
      if (uriResponse.statusCode != 200) return null;

      // Play.
      final playBody = _buildSoapEnvelope(
        'Play', '<InstanceID>0</InstanceID><Speed>1</Speed>');
      await http
          .post(
            Uri.parse(controlUrl),
            headers: _soapHeaders('Play'),
            body: playBody,
          )
          .timeout(const Duration(seconds: 5));

      final controller = DlnaController(
        controlUrl: controlUrl,
        deviceName: deviceName ?? 'DLNA Device',
      );
      controller._state = CastSessionState.playing;
      controller.startPolling();
      return controller;
    } catch (_) {
      return null;
    }
  }

  // ─── Position Polling ────────────────────────────────────────────────────

  void startPolling() {
    stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    _poll(); // Immediate first poll.
  }

  Future<void> _poll() async {
    try {
      if (_wrapper != null) {
        // Use dlna_dart for position + transport state (cleaner XML parsing).
        final posXml = await _wrapper!.position();
        final transportXml = await _wrapper!.getTransportInfo();

        final relTime = _parseRelTimeFromXml(posXml);
        final transportState = _parseTransportStateFromXml(transportXml);

        _position = CastPosition(
          remotePosition: _parseDuration(relTime),
          isPlaying: transportState == 'PLAYING',
          syncOffset: _position.syncOffset,
          estimatedLatency: _position.estimatedLatency,
        );
        _state = transportState == 'PLAYING'
            ? CastSessionState.playing
            : CastSessionState.paused;
      } else {
        // Fallback: raw SOAP polling (current behavior).
        final body = _buildSoapEnvelope(
          'GetPositionInfo', '<InstanceID>0</InstanceID>');
        final response = await http
            .post(
              Uri.parse(_controlUrl),
              headers: {
                'Content-Type': 'text/xml; charset="utf-8"',
                'SOAPACTION':
                    '"urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo"',
              },
              body: body,
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final doc = html_parser.parse(response.body);
          final relTime = doc
                  .getElementsByTagName('RelTime')
                  .firstOrNull
                  ?.text ??
              '00:00:00';
          final transportState = doc
                  .getElementsByTagName('TransportState')
                  .firstOrNull
                  ?.text ??
              '';

          _position = CastPosition(
            remotePosition: _parseDuration(relTime),
            isPlaying: transportState == 'PLAYING',
            syncOffset: _position.syncOffset,
            estimatedLatency: _position.estimatedLatency,
          );
          _state = transportState == 'PLAYING'
              ? CastSessionState.playing
              : _position.isPlaying
                  ? CastSessionState.playing
                  : CastSessionState.paused;
        } else {
          _handleFailure();
          return;
        }
      }
      _consecutiveFailures = 0;
      notifyListeners();
    } catch (_) {
      _handleFailure();
    }
  }

  void _handleFailure() {
    _consecutiveFailures++;
    if (_consecutiveFailures >= _maxFailures) {
      stopPolling();
      _state = CastSessionState.ended;
      notifyListeners();
    }
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ─── Playback Control ────────────────────────────────────────────────────

  Future<void> play() async {
    if (_wrapper != null) {
      await _wrapper!.play();
    } else {
      final body = _buildSoapEnvelope(
        'Play', '<InstanceID>0</InstanceID><Speed>1</Speed>');
      try {
        await http.post(Uri.parse(_controlUrl),
            headers: _soapHeaders('Play'), body: body);
      } catch (_) {}
    }
    _state = CastSessionState.playing;
    notifyListeners();
  }

  Future<void> pause() async {
    if (_wrapper != null) {
      await _wrapper!.pause();
    } else {
      final body =
          _buildSoapEnvelope('Pause', '<InstanceID>0</InstanceID>');
      try {
        await http.post(Uri.parse(_controlUrl),
            headers: _soapHeaders('Pause'), body: body);
      } catch (_) {}
    }
    _state = CastSessionState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    stopPolling();
    if (_wrapper != null) {
      await _wrapper!.stop();
    } else {
      final body =
          _buildSoapEnvelope('Stop', '<InstanceID>0</InstanceID>');
      try {
        await http.post(Uri.parse(_controlUrl),
            headers: _soapHeaders('Stop'), body: body);
      } catch (_) {}
    }
    _state = CastSessionState.ended;
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_state == CastSessionState.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekForward(Duration amount) async {
    await seek(_position.remotePosition + amount);
  }

  Future<void> seekBackward(Duration amount) async {
    final target = _position.remotePosition - amount;
    await seek(target < Duration.zero ? Duration.zero : target);
  }

  @override
  bool get isPlaying => _position.isPlaying;

  @override
  Duration get syncOffset => _position.syncOffset;

  Future<void> seek(Duration position) async {
    final timeStr = _formatDuration(position);
    if (_wrapper != null) {
      await _wrapper!.seek(timeStr);
    } else {
      final body = _buildSoapEnvelope(
        'Seek',
        '<InstanceID>0</InstanceID><Unit>REL_TIME</Unit><Target>$timeStr</Target>',
      );
      try {
        await http.post(Uri.parse(_controlUrl),
            headers: _soapHeaders('Seek'), body: body);
      } catch (_) {}
    }
    _position = CastPosition(
      remotePosition: position,
      isPlaying: _position.isPlaying,
      syncOffset: _position.syncOffset,
      estimatedLatency: _position.estimatedLatency,
    );
    notifyListeners();
  }

  // ─── Volume & Mute (only available when wrapper is set) ──────────────────

  /// Whether volume control is available for this session.
  bool get hasVolumeControl => _wrapper != null;

  /// Sets the volume level (0-100).
  Future<void> setVolume(int level) async {
    if (_wrapper == null) return;
    await _wrapper!.volume(level.clamp(0, 100));
  }

  /// Gets the current volume level.
  Future<int?> getVolume() async {
    if (_wrapper == null) return null;
    try {
      final xml = await _wrapper!.getVolume();
      return _parseVolumeFromXml(xml);
    } catch (_) {
      return null;
    }
  }

  /// Toggles mute state.
  Future<void> setMute(bool mute) async {
    if (_wrapper == null) return;
    await _wrapper!.mute(mute);
  }

  /// Changes volume by a relative amount (e.g., +5 or -10).
  Future<void> changeVolume(int delta) async {
    if (_wrapper == null) return;
    await _wrapper!.changeVolume(delta);
  }

  // ─── Track Navigation (only available when wrapper is set) ───────────────

  /// Whether track navigation (next/previous) is available.
  bool get hasTrackNavigation => _wrapper != null;

  Future<void> next() async {
    if (_wrapper == null) return;
    await _wrapper!.next();
  }

  Future<void> previous() async {
    if (_wrapper == null) return;
    await _wrapper!.previous();
  }

  // ─── Sync Offset ─────────────────────────────────────────────────────────

  void adjustSyncOffset(Duration delta) {
    _position = CastPosition(
      remotePosition: _position.remotePosition,
      isPlaying: _position.isPlaying,
      syncOffset: _position.syncOffset + delta,
      estimatedLatency: _position.estimatedLatency,
    );
    notifyListeners();
  }

  void resetSyncOffset() {
    _position = CastPosition(
      remotePosition: _position.remotePosition,
      isPlaying: _position.isPlaying,
      syncOffset: Duration.zero,
      estimatedLatency: _position.estimatedLatency,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  // ─── Static Helpers ──────────────────────────────────────────────────────

  static String _buildSoapEnvelope(String action, String body) {
    return '<?xml version="1.0" encoding="utf-8"?>'
        '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" '
        's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
        '<s:Body>'
        '<u:$action xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">'
        '$body'
        '</u:$action>'
        '</s:Body>'
        '</s:Envelope>';
  }

  static Map<String, String> _soapHeaders(String action) => {
        'Content-Type': 'text/xml; charset="utf-8"',
        'SOAPACTION':
            '"urn:schemas-upnp-org:service:AVTransport:1#$action"',
      };

  static Duration _parseDuration(String hhmmss) {
    final parts = hhmmss.split(':');
    if (parts.length != 3) return Duration.zero;
    return Duration(
      hours: int.tryParse(parts[0]) ?? 0,
      minutes: int.tryParse(parts[1]) ?? 0,
      seconds: int.tryParse(parts[2]) ?? 0,
    );
  }

  static String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Parses RelTime from GetPositionInfo XML response.
  static String _parseRelTimeFromXml(String xml) {
    try {
      final start = xml.indexOf('<RelTime>');
      final end = xml.indexOf('</RelTime>');
      if (start >= 0 && end > start) {
        return xml.substring(start + 9, end);
      }
    } catch (_) {}
    return '00:00:00';
  }

  /// Parses TransportState from GetTransportInfo XML response.
  static String _parseTransportStateFromXml(String xml) {
    try {
      final start = xml.indexOf('<CurrentTransportState>');
      final end = xml.indexOf('</CurrentTransportState>');
      if (start >= 0 && end > start) {
        return xml.substring(start + 24, end);
      }
    } catch (_) {}
    return 'STOPPED';
  }

  /// Parses CurrentVolume from GetVolume XML response.
  static int _parseVolumeFromXml(String xml) {
    try {
      final start = xml.indexOf('<CurrentVolume>');
      final end = xml.indexOf('</CurrentVolume>');
      if (start >= 0 && end > start) {
        return int.tryParse(xml.substring(start + 15, end)) ?? 0;
      }
    } catch (_) {}
    return 0;
  }
}
