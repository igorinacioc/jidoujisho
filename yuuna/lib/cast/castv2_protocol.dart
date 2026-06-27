import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Implements the Google CastV2 protocol over TLS.
///
/// Connects to a Chromecast device on port 8009, performs the TLS handshake,
/// and sends/receives protobuf-framed CastMessage payloads.
///
/// Protocol reference:
/// * [CastV2 Protocol](https://developers.google.com/cast/docs/reference/messages)
/// * Default Media Receiver app ID: `CC1AD845`
class CastV2Connection {
  final String _host;
  final int _port;
  final String _sourceId;
  final String _destinationId;

  SecureSocket? _socket;
  Completer<void>? _ready;
  int _requestId = 1;

  Timer? _heartbeatTimer;
  Timer? _pollTimer;

  /// The current playback position reported by the receiver.
  Duration currentPosition = Duration.zero;

  /// Whether the remote session is currently playing.
  bool isPlaying = false;

  /// Whether the connection is active.
  bool get isConnected => _socket != null && _ready != null;

  /// Fires whenever the connection state changes.
  final StreamController<void> onChange = StreamController<void>.broadcast();

  CastV2Connection({
    required String host,
    int port = 8009,
  })  : _host = host,
        _port = port,
        _sourceId = 'sender-${DateTime.now().millisecondsSinceEpoch}',
        _destinationId = 'receiver-0';

  // ─── Connection Lifecycle ────────────────────────────────────────────────

  /// Connects via TLS and establishes the Cast session.
  Future<bool> connect() async {
    try {
      _socket = await SecureSocket.connect(
        _host,
        _port,
        timeout: const Duration(seconds: 10),
        onBadCertificate: (_) => true, // Accept self-signed certs.
      );
      _socket!.setOption(SocketOption.tcpNoDelay, true);

      // Send CONNECT message to establish the session.
      await _sendJson(
        namespace: 'urn:x-cast:com.google.cast.tp.connection',
        payload: {'type': 'CONNECT'},
      );

      // Wait for the CONNECT response.
      _ready = Completer<void>();
      _listen();
      await _ready!.future.timeout(const Duration(seconds: 5));

      // Start heartbeat.
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _ping(),
      );

      return true;
    } catch (e) {
      disconnect();
      return false;
    }
  }

  /// Disconnects and cleans up.
  void disconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    stopPolling();
    try {
      _sendJson(
        namespace: 'urn:x-cast:com.google.cast.tp.connection',
        payload: {'type': 'CLOSE'},
      );
    } catch (_) {}
    _socket?.destroy();
    _socket = null;
    _ready = null;
    onChange.add(null);
  }

  // ─── Heartbeat ───────────────────────────────────────────────────────────

  Future<void> _ping() async {
    try {
      await _sendJson(
        namespace: 'urn:x-cast:com.google.cast.tp.heartbeat',
        payload: {'type': 'PING'},
      );
    } catch (_) {
      disconnect();
    }
  }

  // ─── Receiver Control ─────────────────────────────────────────────────────

  /// Launches the Default Media Receiver app (CC1AD845) on the Chromecast.
  Future<bool> launchReceiver() async {
    try {
      await _sendJson(
        namespace: 'urn:x-cast:com.google.cast.receiver',
        payload: {
          'type': 'LAUNCH',
          'appId': 'CC1AD845',
          'requestId': _nextRequestId(),
        },
      );
      // Give the receiver time to launch.
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Media Control ────────────────────────────────────────────────────────

  /// Loads media on the Chromecast receiver.
  ///
  /// [url] must be accessible from the Chromecast (with CORS headers).
  /// [title] is displayed in the Chromecast UI.
  /// [contentType] is the MIME type (e.g. "video/mp4").
  /// [imageUrl] optional poster image.
  Future<bool> loadMedia({
    required String url,
    required String contentType,
    String? title,
    String? imageUrl,
    List<CastV2Subtitle>? subtitles,
  }) async {
    try {
      final media = <String, dynamic>{
        'contentId': url,
        'contentType': contentType,
        'streamType': 'BUFFERED',
        'metadata': {
          'type': 0,
          'metadataType': 0,
          'title': title ?? 'Stream',
        },
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        media['metadata']!['images'] = [
          {'url': imageUrl}
        ];
      }

      if (subtitles != null && subtitles.isNotEmpty) {
        media['tracks'] = subtitles
            .map((s) => {
                  'trackId': s.trackId,
                  'type': 'TEXT',
                  'trackContentType': 'text/vtt',
                  'trackContentId': s.url,
                  'language': s.language,
                  'name': s.name,
                  'subtype': 'SUBTITLES',
                })
            .toList();
      }

      final loadRequestId = _nextRequestId();
      await _sendJson(
        namespace: 'urn:x-cast:com.google.cast.media',
        payload: {
          'type': 'LOAD',
          'requestId': loadRequestId,
          'autoPlay': true,
          'media': media,
        },
      );

      currentPosition = Duration.zero;
      isPlaying = true;
      onChange.add(null);

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sends a PLAY command.
  Future<void> play() async {
    try {
      await _sendMediaMessage('PLAY');
      isPlaying = true;
      onChange.add(null);
    } catch (_) {}
  }

  /// Sends a PAUSE command.
  Future<void> pause() async {
    try {
      await _sendMediaMessage('PAUSE');
      isPlaying = false;
      onChange.add(null);
    } catch (_) {}
  }

  /// Sends a STOP command.
  Future<void> stop() async {
    try {
      await _sendMediaMessage('STOP');
      isPlaying = false;
      onChange.add(null);
    } catch (_) {}
  }

  /// Seeks to an absolute position.
  Future<void> seek(Duration position) async {
    try {
      await _sendJson(
        namespace: 'urn:x-cast:com.google.cast.media',
        payload: {
          'type': 'SEEK',
          'requestId': _nextRequestId(),
          'currentTime': position.inSeconds,
        },
      );
      currentPosition = position;
      onChange.add(null);
    } catch (_) {}
  }

  /// Requests a status update from the receiver.
  Future<void> getStatus() async {
    try {
      await _sendJson(
        namespace: 'urn:x-cast:com.google.cast.media',
        payload: {
          'type': 'GET_STATUS',
          'requestId': _nextRequestId(),
        },
      );
    } catch (_) {}
  }

  // ─── Polling ─────────────────────────────────────────────────────────────

  Timer? _pollTimerHandle;

  void startPolling(Duration interval) {
    stopPolling();
    _pollTimerHandle = Timer.periodic(interval, (_) => getStatus());
    getStatus(); // Immediate first poll.
  }

  void stopPolling() {
    _pollTimerHandle?.cancel();
    _pollTimerHandle = null;
  }

  // ─── Internal Messaging ───────────────────────────────────────────────────

  Future<void> _sendMediaMessage(String type) async {
    await _sendJson(
      namespace: 'urn:x-cast:com.google.cast.media',
      payload: {
        'type': type,
        'requestId': _nextRequestId(),
        'mediaSessionId': 1,
      },
    );
  }

  Future<void> _sendJson({
    required String namespace,
    required Map<String, dynamic> payload,
  }) async {
    final socket = _socket;
    if (socket == null) throw StateError('Not connected.');
    final jsonStr = jsonEncode(payload);
    final jsonBytes = utf8.encode(jsonStr);
    final payloadBytes = Uint8List.fromList(jsonBytes);
    final message = _buildMessage('$namespace', payloadBytes);
    socket.add(message);
    await socket.flush();
  }

  Uint8List _buildMessage(String namespace, Uint8List payloadUtf8) {
    // CastMessage protobuf (simplified hand-written serialization).
    // See: https://developers.google.com/cast/docs/reference/messages
    //
    // Wire format:
    //   uint32 big-endian length prefix (4 bytes)
    //   followed by CastMessage protobuf:
    //     field 1 (string, tag=0x0A): protocol_version = "CASTV2_1_0"
    //     field 2 (string, tag=0x12): source_id
    //     field 3 (string, tag=0x1A): destination_id
    //     field 4 (string, tag=0x22): namespace
    //     field 5 (enum, tag=0x28): payload_type = 0 (STRING)
    //     field 6 (string, tag=0x32): payload_utf8

    // Encode each string field with proper protobuf varint tags.
    final protoVersion = _protoString(1, 'CASTV2_1_0');
    final sourceId = _protoString(2, _sourceId);
    final destId = _protoString(3, _destinationId);
    final ns = _protoString(4, namespace);
    final payloadType = Uint8List.fromList([0x28, 0x00]); // payload_type = STRING(0)
    final payloadUtf8Field = _protoBytes(6, payloadUtf8);

    final protoBody = Uint8List.fromList([
      ...protoVersion,
      ...sourceId,
      ...destId,
      ...ns,
      ...payloadType,
      ...payloadUtf8Field,
    ]);

    // Prepend big-endian 4-byte length prefix.
    final length = protoBody.length;
    final prefix = Uint8List(4);
    prefix.buffer.asByteData().setUint32(0, length, Endian.big);

    return Uint8List.fromList([...prefix, ...protoBody]);
  }

  Uint8List _protoString(int fieldNumber, String value) {
    final tag = (fieldNumber << 3) | 2; // wire type 2 = length-delimited
    final bytes = utf8.encode(value);
    return _protoBytesRaw(tag, bytes);
  }

  Uint8List _protoBytes(int fieldNumber, Uint8List bytes) {
    final tag = (fieldNumber << 3) | 2;
    return _protoBytesRaw(tag, bytes);
  }

  Uint8List _protoBytesRaw(int tag, List<int> bytes) {
    return Uint8List.fromList([..._varint(tag), ..._varint(bytes.length), ...bytes]);
  }

  List<int> _varint(int value) {
    final result = <int>[];
    var v = value;
    while (v > 0x7F) {
      result.add((v & 0x7F) | 0x80);
      v >>= 7;
    }
    if (result.isEmpty) result.add(v); else result.add(v);
    return result;
  }

  int _nextRequestId() => _requestId++;

  // ─── Message Parsing ──────────────────────────────────────────────────────

  int _bufferOffset = 0;
  final _buffer = <int>[];

  void _listen() {
    _socket!.listen(
      (data) {
        _buffer.addAll(data);
        _processBuffer();
      },
      onError: (e) => disconnect(),
      onDone: () {},
      cancelOnError: true,
    );
  }

  void _processBuffer() {
    while (_bufferOffset + 4 <= _buffer.length) {
      // Read the 4-byte big-endian length prefix.
      final length = ByteData.view(
        Uint8List.fromList(
          _buffer.sublist(_bufferOffset, _bufferOffset + 4),
        ).buffer,
      ).getUint32(0, Endian.big);

      if (_bufferOffset + 4 + length > _buffer.length) return;

      final protoData = _buffer.sublist(_bufferOffset + 4, _bufferOffset + 4 + length);
      _bufferOffset += 4 + length;

      _parseCastMessage(protoData);
    }

    // Compact buffer.
    if (_bufferOffset > 0 && _bufferOffset >= _buffer.length ~/ 2) {
      _buffer.removeRange(0, _bufferOffset);
      _bufferOffset = 0;
    }
  }

  void _parseCastMessage(List<int> data) {
    try {
      String? namespace;
      String? payloadJson;

      int pos = 0;
      while (pos < data.length) {
        final tagInfo = _readVarintValue(data, pos);
        pos += tagInfo.bytesRead;
        final tag = tagInfo.value;
        final fieldNumber = tag >> 3;
        final wireType = tag & 0x07;

        if (wireType == 2) {
          // Variable-length: string or bytes.
          final lenInfo = _readVarintValue(data, pos);
          pos += lenInfo.bytesRead;
          final length = lenInfo.value;
          final value = utf8.decode(data.sublist(pos, pos + length));
          pos += length;

          if (fieldNumber == 4) {
            namespace = value;
          } else if (fieldNumber == 6) {
            payloadJson = value;
          }
        } else if (wireType == 0 && fieldNumber == 5) {
          // Varint: payload_type.
          final valInfo = _readVarintValue(data, pos);
          pos += valInfo.bytesRead;
        } else {
          break; // Safety: skip unknown fields.
        }
      }

      if (payloadJson != null) {
        _handleMessage(namespace ?? '', payloadJson);
      }

      // If this was a CONNECT response, mark as ready.
      if (namespace == 'urn:x-cast:com.google.cast.tp.connection') {
        _ready?.complete();
      }
    } catch (_) {
      // Malformed message — ignore.
    }
  }

  void _handleMessage(String namespace, String jsonPayload) {
    try {
      final payload = jsonDecode(jsonPayload) as Map<String, dynamic>;
      final type = payload['type'] as String? ?? '';

      if (namespace == 'urn:x-cast:com.google.cast.tp.connection' &&
          type == 'CLOSE') {
        disconnect();
        return;
      }

      if (namespace == 'urn:x-cast:com.google.cast.media') {
        _handleMediaMessage(type, payload);
      }

      if (namespace == 'urn:x-cast:com.google.cast.tp.heartbeat') {
        if (type == 'PONG') return;
        _sendJson(
          namespace: 'urn:x-cast:com.google.cast.tp.heartbeat',
          payload: {'type': 'PONG'},
        );
      }
    } catch (_) {}
  }

  void _handleMediaMessage(String type, Map<String, dynamic> payload) {
    // MEDIA_STATUS response from GET_STATUS.
    if (type == 'MEDIA_STATUS') {
      final status = (payload['status'] as List?)?.firstOrNull as Map<String, dynamic>?;
      if (status != null) {
        final playerState = status['playerState'] as String? ?? 'IDLE';
        isPlaying = playerState == 'PLAYING' || playerState == 'BUFFERING';

        final currentTime = status['currentTime'] as num? ?? 0;
        currentPosition = Duration(seconds: currentTime.toInt());
        onChange.add(null);
      }
    }
  }

  /// Reads a protobuf varint starting at [offset].
  /// Returns a record-like object with [bytesRead] and [value].
  _VarintResult _readVarintValue(List<int> data, int offset) {
    int result = 0;
    int shift = 0;
    int bytesRead = 0;
    while (offset + bytesRead < data.length) {
      final byte = data[offset + bytesRead];
      bytesRead++;
      result |= (byte & 0x7F) << shift;
      shift += 7;
      if ((byte & 0x80) == 0) break;
    }
    return _VarintResult(bytesRead, result);
  }
}

/// Simple result holder for varint parsing.
class _VarintResult {
  final int bytesRead;
  final int value;
  const _VarintResult(this.bytesRead, this.value);
}

/// Represents a subtitle track to send to the Chromecast.
class CastV2Subtitle {
  final int trackId;
  final String url;
  final String language;
  final String name;

  const CastV2Subtitle({
    required this.trackId,
    required this.url,
    required this.language,
    required this.name,
  });
}
