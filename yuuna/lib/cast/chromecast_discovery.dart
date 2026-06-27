import 'dart:async';
import 'dart:io';

/// A Chromecast device discovered on the local network via mDNS.
class ChromecastDevice {
  final String name;
  final String host;
  final int port;
  final String id;
  final String? deviceVersion;

  const ChromecastDevice({
    required this.name,
    required this.host,
    required this.port,
    required this.id,
    this.deviceVersion,
  });

  @override
  String toString() => 'ChromecastDevice($name @ $host:$port)';
}

/// Discovers Chromecast devices on the local network via mDNS.
///
/// Sends an mDNS PTR query for `_googlecast._tcp.local` on the
/// multicast address 224.0.0.251:5353 and parses the responses
/// to extract device names, IPs, and ports.
///
/// This complements the existing SSDP discovery in [DeviceDiscovery]
/// which only finds Chromecast gen 1 (via DIAL on port 1900).
///
/// Chromecast gen 2, 3, Ultra, Google TV, and Android TV with
/// Cast built-in all use mDNS exclusively for discovery.
class ChromecastDiscovery {
  static const _mdnsAddress = '224.0.0.251';
  static const _mdnsPort = 5353;
  static const _serviceName = '_googlecast._tcp.local';
  static const _discoveryTimeout = Duration(seconds: 4);

  /// Discovers all Chromecast devices on the local network.
  static Future<List<ChromecastDevice>> discover() async {
    final devices = <String, ChromecastDevice>{};

    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (_) {
      return [];
    }

    final query = _buildPtrQuery(_serviceName);
    try {
      socket.send(query, InternetAddress(_mdnsAddress), _mdnsPort);
    } catch (_) {}

    final completer = Completer<void>();
    Timer(_discoveryTimeout, () {
      if (!completer.isCompleted) completer.complete();
    });

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket?.receive();
        if (datagram != null) {
          final device = _parseMdnsResponse(datagram.data, datagram.address.address);
          if (device != null) {
            devices[device.id] = device;
          }
        }
      }
    }, onDone: () {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;
    try { socket.close(); } catch (_) {}
    return devices.values.toList();
  }

  static List<int> _buildPtrQuery(String serviceName) {
    final buf = <int>[];
    final transactionId = (DateTime.now().millisecondsSinceEpoch & 0xFFFF);
    // DNS Header.
    buf.addAll([(transactionId >> 8) & 0xFF, transactionId & 0xFF,
                0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
    _encodeDnsName(serviceName).forEach((l) => buf.addAll(l));
    buf.addAll([0x00, 0x0C, 0x00, 0x01]); // PTR, IN
    return buf;
  }

  static ChromecastDevice? _parseMdnsResponse(List<int> data, String sourceIp) {
    if (data.length < 12) return null;
    final flags1 = data[2];
    if ((flags1 & 0x80) == 0) return null; // Not a response.
    final qdCount = (data[4] << 8) | data[5];
    final anCount = (data[6] << 8) | data[7];
    int pos = 12;
    for (int i = 0; i < qdCount && pos < data.length; i++) {
      pos = _skipDnsName(data, pos) + 4;
    }
    for (int i = 0; i < anCount && pos < data.length; i++) {
      pos = _skipDnsName(data, pos);
      if (pos + 10 > data.length) break;
      final rtype = (data[pos] << 8) | data[pos + 1];
      final rdlength = (data[pos + 8] << 8) | data[pos + 9];
      pos += 10;
      if (pos + rdlength > data.length) break;
      if (rtype == 16) {
        final txt = _parseTxtRecord(data.sublist(pos, pos + rdlength));
        return ChromecastDevice(
          name: txt['fn'] ?? 'Chromecast',
          host: sourceIp,
          port: 8009,
          id: txt['id'] ?? sourceIp,
          deviceVersion: txt['ve'],
        );
      } else if (rtype == 33 && rdlength >= 6) {
        // SRV record: extract port.
        final port = (data[pos + 4] << 8) | data[pos + 5];
        // Name will come from a subsequent TXT record.
      }
      pos += rdlength;
    }
    return ChromecastDevice(name: 'Chromecast', host: sourceIp, port: 8009, id: sourceIp);
  }

  static List<List<int>> _encodeDnsName(String name) {
    final result = <List<int>>[];
    for (final part in name.split('.')) {
      if (part.isEmpty) continue;
      result.add([part.length, ...part.codeUnits]);
    }
    result.add([0x00]);
    return result;
  }

  static int _skipDnsName(List<int> data, int pos) {
    while (pos < data.length) {
      final len = data[pos];
      if (len == 0x00) return pos + 1;
      if ((len & 0xC0) == 0xC0) return pos + 2;
      pos += 1 + len;
    }
    return pos;
  }

  static Map<String, String> _parseTxtRecord(List<int> data) {
    final result = <String, String>{};
    int pos = 0;
    while (pos < data.length) {
      final len = data[pos]; pos++;
      if (pos + len > data.length) break;
      final entry = String.fromCharCodes(data.sublist(pos, pos + len));
      pos += len;
      final eqIdx = entry.indexOf('=');
      if (eqIdx > 0) result[entry.substring(0, eqIdx)] = entry.substring(eqIdx + 1);
    }
    return result;
  }
}
