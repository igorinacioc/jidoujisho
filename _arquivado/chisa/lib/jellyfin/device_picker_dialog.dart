import 'package:flutter/material.dart';

import 'jellyfin_models.dart';

/// A dialog that shows available Chromecast/TV devices from Jellyfin
/// and lets the user pick one to cast to.
///
/// Returns the selected [JellyfinDevice], or null if cancelled.
class DevicePickerDialog extends StatelessWidget {
  const DevicePickerDialog({
    required this.devices,
    required this.serverName,
    Key? key,
  }) : super(key: key);

  /// List of available devices from Jellyfin.
  final List<JellyfinDevice> devices;

  /// Name of the connected Jellyfin server.
  final String serverName;

  /// Shows the device picker dialog.
  ///
  /// Returns the selected [JellyfinDevice], or null if dismissed.
  static Future<JellyfinDevice?> show({
    required BuildContext context,
    required List<JellyfinDevice> devices,
    required String serverName,
  }) async {
    return showDialog<JellyfinDevice>(
      context: context,
      builder: (ctx) => DevicePickerDialog(
        devices: devices,
        serverName: serverName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final castDevices = devices.where((d) => d.isCastDevice).toList();
    final otherDevices = devices.where((d) => !d.isCastDevice).toList();

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Row(
        children: [
          const Icon(Icons.cast, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cast to Device',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serverName,
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            if (castDevices.isEmpty && otherDevices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No devices found.\n'
                    'Make sure your TV is on and connected to the same network.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Cast-capable devices first.
            if (castDevices.isNotEmpty) ...[
              Text(
                'TV & CAST DEVICES',
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...castDevices.map((d) => _buildDeviceTile(context, d, isCast: true)),
              const SizedBox(height: 12),
            ],

            // Other devices.
            if (otherDevices.isNotEmpty) ...[
              Text(
                'OTHER DEVICES',
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...otherDevices.map((d) => _buildDeviceTile(context, d, isCast: false)),
            ],

            const SizedBox(height: 8),

            // Refresh hint
            Center(
              child: Text(
                'Not seeing your device? Make sure it\'s on the same Wi-Fi.',
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// Builds a single device tile.
  Widget _buildDeviceTile(
    BuildContext context,
    JellyfinDevice device, {
    bool isCast = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isCast ? Icons.tv : Icons.phone_android,
        color: isCast
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).unselectedWidgetColor,
        size: 24,
      ),
      title: Text(device.name),
      subtitle: device.appName != null
          ? Text(
              device.appName!,
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontSize: 12,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pop(context, device),
    );
  }
}
