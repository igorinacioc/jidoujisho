import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'cast_models.dart';

/// Controls a DLNA/UPnP cast session via raw SOAP/UPnP.
///
/// Sends a stream URL to a TV/renderer via UPnP AVTransport,
/// then polls the playback position for subtitle synchronization.
///
/// Uses CDATA in SOAP envelopes to prevent XML entity corruption of URLs
/// (the `&` → `&amp;` bug that broke query params on many TVs).
///
/// Used by [MiningModePage] to keep subtitles in sync with the TV.
class DlnaController extends CastSession {
  final String _controlUrl;
  final String _deviceName;

  DlnaController({
    required String controlUrl,
    required String deviceName,
  })  : _controlUrl = controlUrl,
        _deviceName = deviceName;

  // ─── State ─────────────────────────────────────────────────────────────

  CastSessionState _state = CastSessionState.connecting;
  CastPosition _position = CastPosition.empty;
  Timer? _pollTimer;
  int _consecutiveFailures = 0;
  static const int _maxFailures = 5;
  static const Duration _pollInterval = Duration(milliseconds: 500);

  // ─── Getters ───────────────────────────────────────────────────────────

  CastSessionState get state => _state;
  CastPosition get position => _position;
  String get deviceName => _deviceName;
  String get controlUrl => _controlUrl;
  bool get isActive =>
      _state == CastSessionState.playing || _state == CastSessionState.paused;

  /// The sync-adjusted position for subtitle matching.
  Duration get syncedPosition => _position.syncedPosition;

  // ─── Startup ───────────────────────────────────────────────────────────

  /// Sends a stream URL to the DLNA renderer and starts playback.
  static Future<DlnaController?> connect({
    required String streamUrl,
    required String deviceLocationUrl,
    String? deviceName,
  }) async {
    try {
      // 1. Fetch device description XML to find AVTransport control URL.
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

      // 2. Send SetAVTransportURI (use CDATA to avoid XML-entity-corrupted URLs).
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

      // 3. Send Play.
      final playBody = _buildSoapEnvelope(
        'Play',
        '<InstanceID>0</InstanceID><Speed>1</Speed>',
      );
      await http
          .post(
            Uri.parse(controlUrl),
            headers: {
              'Content-Type': 'text/xml; charset="utf-8"',
              'SOAPACTION':
                  '"urn:schemas-upnp-org:service:AVTransport:1#Play"',
            },
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

  // ─── Position Polling ─────────────────────────────────────────────────

  void startPolling() {
    stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    _poll(); // Immediate first poll.
  }

  Future<void> _poll() async {
    try {
      final body = _buildSoapEnvelope(
        'GetPositionInfo',
        '<InstanceID>0</InstanceID>',
      );
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
        final relTime =
            doc.getElementsByTagName('RelTime').firstOrNull?.text ?? '00:00:00';
        final transportState =
            doc.getElementsByTagName('TransportState').firstOrNull?.text ?? '';

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
        _consecutiveFailures = 0;
        notifyListeners();
      } else {
        _handleFailure();
      }
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

  // ─── Playback Control ──────────────────────────────────────────────────

  Future<void> play() async {
    final body = _buildSoapEnvelope(
      'Play', '<InstanceID>0</InstanceID><Speed>1</Speed>');
    try {
      await http.post(
        Uri.parse(_controlUrl),
        headers: _soapHeaders('Play'),
        body: body,
      );
      _state = CastSessionState.playing;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> pause() async {
    final body = _buildSoapEnvelope('Pause', '<InstanceID>0</InstanceID>');
    try {
      await http.post(
        Uri.parse(_controlUrl),
        headers: _soapHeaders('Pause'),
        body: body,
      );
      _state = CastSessionState.paused;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> stop() async {
    stopPolling();
    final body = _buildSoapEnvelope('Stop', '<InstanceID>0</InstanceID>');
    try {
      await http.post(
        Uri.parse(_controlUrl),
        headers: _soapHeaders('Stop'),
        body: body,
      );
    } catch (_) {}
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
    final body = _buildSoapEnvelope(
      'Seek',
      '<InstanceID>0</InstanceID><Unit>REL_TIME</Unit><Target>$timeStr</Target>',
    );
    try {
      await http.post(
        Uri.parse(_controlUrl),
        headers: _soapHeaders('Seek'),
        body: body,
      );
      _position = CastPosition(
        remotePosition: position,
        isPlaying: _position.isPlaying,
        syncOffset: _position.syncOffset,
        estimatedLatency: _position.estimatedLatency,
      );
      notifyListeners();
    } catch (_) {}
  }

  // ─── Sync Offset ──────────────────────────────────────────────────────

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

  // ─── Static Helpers ────────────────────────────────────────────────────

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

  Map<String, String> _soapHeaders(String action) => {
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
}
