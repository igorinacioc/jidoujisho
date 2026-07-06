import 'dart:async';

import 'package:flutter/material.dart';

import 'cast_models.dart';

/// Draggable bottom-sheet dialog for selecting a cast target.
///
/// Like YouTube's Cast dialog:
/// - Opens instantly with cached devices + live discovery stream
/// - Can be dragged up to fill the screen, down to dismiss
/// - Refresh button to re-scan the network
/// - Green dot on newly discovered devices
class DevicePicker extends StatefulWidget {
  /// Devices shown instantly (cached from previous discovery).
  final List<CastTarget>? initialDevices;

  /// Stream of cumulative device lists as discovery progresses.
  final Stream<List<CastTarget>>? deviceStream;

  /// Called when the user taps a device.
  final ValueChanged<CastTarget> onSelect;

  /// Called when the user taps refresh — should restart discovery.
  final VoidCallback? onRefresh;

  const DevicePicker({
    super.key,
    this.initialDevices,
    this.deviceStream,
    required this.onSelect,
    this.onRefresh,
  });

  /// Shows the device picker as a fully draggable bottom sheet.
  ///
  /// The sheet can be dragged up to fill the screen or down to dismiss.
  /// Devices appear incrementally as they're discovered.
  ///
  /// Returns the selected [CastTarget], or null if cancelled.
  static Future<CastTarget?> show({
    required BuildContext context,
    List<CastTarget>? initialDevices,
    Stream<List<CastTarget>>? deviceStream,
    VoidCallback? onRefresh,
  }) {
    return showModalBottomSheet<CastTarget>(
      context: context,
      isScrollControlled: true,
      // Let the sheet use as much height as it needs — no fixed cap.
      // The user drags freely: up to expand, down to dismiss.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (ctx) => DevicePicker(
        initialDevices: initialDevices,
        deviceStream: deviceStream,
        onSelect: (device) => Navigator.pop(ctx, device),
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  State<DevicePicker> createState() => _DevicePickerState();
}

class _DevicePickerState extends State<DevicePicker> {
  List<CastTarget> _devices = [];
  bool _isSearching = true;
  int _lastBatchSize = 0;
  int _prevCount = 0;
  StreamSubscription<List<CastTarget>>? _sub;

  @override
  void initState() {
    super.initState();
    if (widget.initialDevices != null) {
      _devices = List.from(widget.initialDevices!);
      _prevCount = _devices.length;
      _isSearching = widget.deviceStream != null;
    }
    _listenToStream();
  }

  void _listenToStream() {
    _sub?.cancel();
    _sub = widget.deviceStream?.listen((updated) {
      if (!mounted) return;
      setState(() {
        _lastBatchSize = updated.length - _prevCount;
        _prevCount = updated.length;
        _devices = updated;
        _isSearching = true;
      });
    }, onDone: () {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _lastBatchSize = 0;
      });
    }, onError: (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _lastBatchSize = 0;
      });
    });
  }

  void _handleRefresh() {
    if (widget.onRefresh == null) return;
    setState(() {
      _isSearching = true;
      _lastBatchSize = 0;
      _prevCount = _devices.length;
    });
    widget.onRefresh!();
    // Re-attach to the (now refreshed) stream so new results show up.
    _listenToStream();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle — YouTube-style pill.
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
          child: Row(
            children: [
              Text(
                'Cast to...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (widget.onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Scan again',
                  onPressed: _handleRefresh,
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Searching indicator — compact, non-intrusive.
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text(
                  'Searching for devices...',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

        const Divider(height: 1),

        // Content area — scrollable, fills available space.
        if (_devices.isEmpty && !_isSearching)
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
        else if (_devices.isEmpty && _isSearching)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.wifi_find, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Looking for devices on your network...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                final isNew = _isSearching &&
                    _lastBatchSize > 0 &&
                    index >= _devices.length - _lastBatchSize;
                return _DeviceTile(
                  device: device,
                  isNew: isNew,
                  onTap: () => widget.onSelect(device),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final CastTarget device;
  final VoidCallback onTap;
  final bool isNew;

  const _DeviceTile({
    required this.device,
    required this.onTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _icon(device.icon),
      title: Row(
        children: [
          Flexible(child: Text(device.name)),
          if (isNew) const SizedBox(width: 6),
          if (isNew)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      subtitle: Text(device.type),
      trailing: device.isChromecast
          ? const Chip(
              label: Text('Chromecast', style: TextStyle(fontSize: 10)))
          : device.dlnaDevice != null
              ? const Chip(
                  label: Text('DLNA', style: TextStyle(fontSize: 10)))
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
