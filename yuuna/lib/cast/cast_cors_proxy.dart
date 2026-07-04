import 'dart:async';
import 'dart:io';

/// A lightweight HTTP proxy that adds CORS headers to Jellyfin streams.
///
/// Chromecast requires `Access-Control-Allow-Origin: *` on all media URLs.
/// Jellyfin doesn't always return CORS headers, so we proxy through this
/// local server to inject them.
///
/// The proxy preserves the full original stream URL (path + query params)
/// so the Chromecast receives the actual video stream, not just the server
/// root.
///
/// Usage:
/// ```dart
/// final proxy = await CastCorsProxy.start('http://192.168.0.73:8096/Videos/...');
/// print(proxy.publicUrl); // http://192.168.0.100:54321/stream
/// // Use this URL as the contentId for Chromecast LOAD.
/// ```
class CastCorsProxy {
  HttpServer? _server;
  final String _targetBase;
  final String _targetPathAndQuery;
  final String _host;
  final String _targetHost;
  final int _targetPort;
  final bool _targetIsHttps;

  CastCorsProxy._({
    required String targetBase,
    required String targetPathAndQuery,
    required String host,
    required String targetHost,
    required int targetPort,
    required bool targetIsHttps,
  })  : _targetBase = targetBase,
        _targetPathAndQuery = targetPathAndQuery,
        _host = host,
        _targetHost = targetHost,
        _targetPort = targetPort,
        _targetIsHttps = targetIsHttps;

  /// The URL that the Chromecast should connect to.
  String get publicUrl => 'http://$_host:${_server!.port}/stream';

  /// Whether the proxy server is currently running.
  bool get isRunning => _server != null;

  /// Starts the proxy server on a random available port.
  static Future<CastCorsProxy?> start(String targetUrl) async {
    try {
      final uri = Uri.parse(targetUrl);

      // Find our own IP for the Chromecast to reach us.
      final hostIp = await _findLocalIp(uri.host);
      if (hostIp == null) return null;

      final server = await HttpServer.bind(InternetAddress(hostIp), 0);
      final targetIsHttps = uri.scheme == 'https';
      final targetPort = uri.port != 0 ? uri.port : (targetIsHttps ? 443 : 80);

      // Build the target base URL (scheme + host + port).
      final targetBase = '${uri.scheme}://${uri.host}:$targetPort';

      // Preserve the original path and query so the proxy forwards to
      // the actual stream endpoint, not just the server root.
      final targetPathAndQuery = uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : '');

      final proxy = CastCorsProxy._(
        targetBase: targetBase,
        targetPathAndQuery: targetPathAndQuery,
        host: hostIp,
        targetHost: uri.host,
        targetPort: targetPort,
        targetIsHttps: targetIsHttps,
      );
      proxy._server = server;

      server.listen((request) async {
        await proxy._handleRequest(request);
      });

      return proxy;
    } catch (_) {
      return null;
    }
  }

  /// Stops the proxy server.
  void stop() {
    _server?.close(force: true);
    _server = null;
  }

  // ─── Request Handling ───────────────────────────────────────────────────

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      // Always forward to the original saved path + query.
      // The Chromecast accesses /stream, but the actual Jellyfin endpoint
      // is /Videos/{id}/stream?Static=true&... preserved in _targetPathAndQuery.
      final targetUrl = '$_targetBase$_targetPathAndQuery';

      // Forward the request to Jellyfin.
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 30)
        ..badCertificateCallback = (_, __, ___) => true; // Accept self-signed.

      final proxyRequest = await client.openUrl(request.method, Uri.parse(targetUrl));

      // Copy relevant headers (but not Host — we're re-targeting).
      request.headers.forEach((name, values) {
        final lower = name.toLowerCase();
        if (lower != 'host' && lower != 'origin' && lower != 'referer') {
          for (final v in values) {
            proxyRequest.headers.add(name, v);
          }
        }
      });

      // Handle Range requests (important for seeking in media).
      if (request.headers.value('range') != null) {
        proxyRequest.headers.set('range', request.headers.value('range')!);
      }

      final proxyResponse = await proxyRequest.close();

      // Write CORS + response headers.
      _writeCorsHeaders(request.response);
      request.response.statusCode = proxyResponse.statusCode;
      request.response.headers.contentType = proxyResponse.headers.contentType;
      request.response.headers.set('accept-ranges', 'bytes');

      final contentLength = proxyResponse.headers.contentLength;
      if (contentLength >= 0) {
        request.response.headers.contentLength = contentLength;
      }

      final contentRange = proxyResponse.headers.value('content-range');
      if (contentRange != null) {
        request.response.headers.set('content-range', contentRange);
      }

      // Stream the response body.
      await request.response.addStream(proxyResponse);
      await request.response.close();

      client.close();
    } catch (_) {
      _writeCorsHeaders(request.response);
      request.response.statusCode = 502;
      request.response.close();
    }
  }

  void _writeCorsHeaders(HttpResponse response) {
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, HEAD');
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Range');
    response.headers.set('Access-Control-Max-Age', '86400');
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  /// Finds the best local IP address to reach the target host.
  static Future<String?> _findLocalIp(String targetHost) async {
    try {
      // Try connecting to the target to discover the best interface.
      final internetAddresses =
          await InternetAddress.lookup(targetHost).timeout(const Duration(seconds: 3));
      if (internetAddresses.isEmpty) return null;

      final targetAddr = internetAddresses.first;

      // Find a local interface that can route to the target.
      for (final interface in await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      )) {
        for (final addr in interface.addresses) {
          // Heuristic: pick an address on the same subnet or a common private range.
          if (addr.address.startsWith('192.168.') ||
              addr.address.startsWith('10.') ||
              addr.address.startsWith('172.')) {
            // Quick check if this interface can reach the target.
            try {
              final socket = await Socket.connect(
                targetAddr,
                targetAddr.type == InternetAddressType.IPv4 ? 80 : 443,
                timeout: const Duration(seconds: 1),
                sourceAddress: addr,
              );
              socket.destroy();
              return addr.address;
            } catch (_) {
              // This interface can't reach the target — try the next.
            }
          }
        }
      }

      // Fallback: return the first private IP found.
      for (final interface in await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      )) {
        for (final addr in interface.addresses) {
          if (addr.address.startsWith('192.168.')) return addr.address;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
