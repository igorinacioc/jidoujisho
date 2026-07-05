import 'package:flutter/material.dart';

import 'cast_models.dart';

/// Bottom-sheet dialog for selecting a cast target.
///
/// Displays a list of discovered devices (SSDP + Jellyfin)
/// and lets the user pick where to cast to.
class DevicePicker extends StatelessWidget {
  final List<CastTarget> devices;
  final ValueChanged<CastTarget> onSelect;

  const DevicePicker({
    super.key,
    required this.devices,
    required this.onSelect,
  });

  /// Shows the device picker as a bottom sheet.
  /// Returns the selected [CastTarget], or null if cancelled.
  static Future<CastTarget?> show({
    required BuildContext context,
    required List<CastTarget> devices,
  }) {
    return showModalBottomSheet<CastTarget>(
      context: context,
      builder: (ctx) => DevicePicker(
        devices: devices,
        onSelect: (device) => Navigator.pop(ctx, device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Cast to...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (devices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.cast, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No cast devices found.\nMake sure your TV is on the same Wi-Fi.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return _DeviceTile(
                    device: device,
                    onTap: () => onSelect(device),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final CastTarget device;
  final VoidCallback onTap;

  const _DeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _icon(device.icon),
      title: Text(device.name),
      subtitle: Text(device.type),
      trailing: device.isChromecast
          ? const Chip(
              label: Text('Chromecast', style: TextStyle(fontSize: 10)))
          : device.dlnaDevice != null
              ? const Chip(label: Text('DLNA', style: TextStyle(fontSize: 10)))
              : device.isDlna
                  ? const Chip(
                      label: Text('DLNA', style: TextStyle(fontSize: 10)))
                  : device.isJellyfin
                      ? const Chip(
                          label: Text('Jellyfin',
                              style: TextStyle(fontSize: 10)))
                      : null,
      onTap: onTap,
    );
  }

  Widget _icon(CastDeviceIcon icon) {
    switch (icon) {
      case CastDeviceIcon.cast:
        return const Icon(Icons.cast, size: 32);
      case CastDeviceIcon.tv:
        return const Icon(Icons.tv, size: 32);
      case CastDeviceIcon.game:
        return const Icon(Icons.videogame_asset, size: 32);
      case CastDeviceIcon.speaker:
        return const Icon(Icons.speaker, size: 32);
    }
  }
}
