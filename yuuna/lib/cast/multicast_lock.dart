import 'package:flutter/services.dart';

/// Acquires and releases a WiFi [MulticastLock] on Android.
///
/// SSDP (DLNA discovery on 239.255.255.250:1900) and mDNS (Chromecast
/// discovery on 224.0.0.251:5353) both require the WiFi driver to allow
/// multicast traffic. On Android API 24+, the driver filters multicast
/// packets by default for power saving. A [MulticastLock] tells the driver
/// to let multicast through during discovery.
///
/// On non-Android platforms this is a no-op.
///
/// Usage:
/// ```dart
/// await MulticastLockHolder.acquire();
/// // ... discover devices via SSDP / mDNS ...
/// await MulticastLockHolder.release();
/// ```
class MulticastLockHolder {
  static const _channel = MethodChannel('app.arianneorpilla.yuuna/multicast');

  /// Acquires the multicast lock. Safe to call multiple times.
  static Future<bool> acquire() async {
    try {
      return await _channel.invokeMethod<bool>('acquire') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Releases the multicast lock. Safe to call even if not held.
  static Future<bool> release() async {
    try {
      return await _channel.invokeMethod<bool>('release') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Whether the lock is currently held.
  static Future<bool> isHeld() async {
    try {
      return await _channel.invokeMethod<bool>('isHeld') ?? false;
    } catch (_) {
      return false;
    }
  }
}
