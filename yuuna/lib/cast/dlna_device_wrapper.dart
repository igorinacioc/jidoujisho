import 'dart:convert';

import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';

/// Wraps [DLNADevice] from the `dlna_dart` package with a critical fix:
///
/// **CDATA URLs**: `dlna_dart` uses `htmlEncode()` on the stream URL in
/// `setUrl()`, which converts `&` → `&amp;` and corrupts query parameters
/// (e.g., Jellyfin tokens). This wrapper overrides `setUrl()` to use XML
/// CDATA sections instead, matching the proven approach in [DlnaController].
///
/// All other methods (play, pause, seek, volume, mute, etc.) delegate
/// directly to the underlying [DLNADevice] — no URL encoding issues there.
class DlnaDeviceWrapper {
  final DLNADevice _device;

  DlnaDeviceWrapper(this._device);

  /// The underlying [DeviceInfo] from SSDP discovery.
  DeviceInfo get info => _device.info;

  // ─── AVTransport (URL uses CDATA) ──────────────────────────────────────

  /// Sends the stream URL to the DLNA renderer using CDATA to prevent
  /// XML-entity corruption of URLs (the `&` → `&amp;` bug).
  Future<String> setUrl(
    String url, {
    String title = '',
    PlayType type = PlayType.Video,
  }) async {
    final meta = _buildDidlMetadata(title, type);
    final body = '''<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
 s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:SetAVTransportURI xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
      <InstanceID>0</InstanceID>
      <CurrentURI><![CDATA[$url]]></CurrentURI>
      <CurrentURIMetaData></CurrentURIMetaData>
    </u:SetAVTransportURI>
  </s:Body>
</s:Envelope>''';
    return _device.request('SetAVTransportURI', Utf8Encoder().convert(body));
  }

  /// Builds minimal DIDL-Lite metadata for the media item.
  ///
  /// Kept private — the wrapper only needs to send a valid DIDL-Lite
  /// fragment so the TV accepts the URI. Full metadata with subtitles
  /// can be added later.
  String _buildDidlMetadata(String title, PlayType type) {
    final classTag = switch (type) {
      PlayType.Video => 'object.item.videoItem',
      PlayType.Audio => 'object.item.audioItem.musicTrack',
      PlayType.Image => 'object.item.imageItem',
    };
    return '<DIDL-Lite'
        ' xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/"'
        ' xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/"'
        ' xmlns:dc="http://purl.org/dc/elements/1.1/">'
        '<item id="0" parentID="-1" restricted="1">'
        '<dc:title>$title</dc:title>'
        '<upnp:class>$classTag</upnp:class>'
        '</item>'
        '</DIDL-Lite>';
  }

  // ─── Playback Control (delegates) ───────────────────────────────────────

  Future<String> play() => _device.play();
  Future<String> pause() => _device.pause();
  Future<String> stop() => _device.stop();
  Future<String> seek(String timeString) => _device.seek(timeString);
  Future<String> position() => _device.position();
  Future<String> next() => _device.next();
  Future<String> previous() => _device.previous();
  Future<String> getTransportInfo() => _device.getTransportInfo();
  Future<String> getMediaInfo() => _device.getMediaInfo();
  Future<String> getCurrentTransportActions() =>
      _device.getCurrentTransportActions();
  Future<String> getDeviceCapabilities() => _device.getDeviceCapabilities();
  Future<String> setPlayMode(String modeName) => _device.setPlayMode(modeName);

  /// Relative seek from current position.
  Future<String> seekByCurrent(String positionXml, int seconds) =>
      _device.seekByCurrent(positionXml, seconds);

  // ─── Volume & Mute (delegates) ──────────────────────────────────────────

  Future<String> volume(int volume) => _device.volume(volume);
  Future<String> getVolume() => _device.getVolume();
  Future<String> mute(bool mute) => _device.mute(mute);
  Future<String> getMute() => _device.getMute();

  /// Relative volume change (e.g., +5 or -10).
  Future<String> changeVolume(int delta) => _device.changeVolume(delta);
}
