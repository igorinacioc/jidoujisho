import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog used for managing Jellyfin server connection.
///
/// Allows the user to enter server URL, username, and password
/// to connect to a Jellyfin media server, or disconnect if already
/// connected.
class JellyfinSettingsDialogPage extends BasePage {
  /// Create an instance of this page.
  const JellyfinSettingsDialogPage({super.key});

  @override
  BasePageState createState() => _JellyfinSettingsDialogPageState();
}

class _JellyfinSettingsDialogPageState extends BasePageState {
  late TextEditingController _serverUrlController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  PlayerJellyfinSource get _source => PlayerJellyfinSource.instance;

  @override
  void initState() {
    super.initState();

    _tryRestoreSession();

    _serverUrlController = TextEditingController(
      text: _source.getPreference<String?>(
            key: 'jellyfin_server_url',
            defaultValue: '',
          ) ??
          '',
    );
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> _tryRestoreSession() async {
    try {
      final restored = await _source.restoreSession();
      if (mounted) setState(() => _isLoggedIn = restored);
    } catch (_) {}
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal.copyWith(
                left: Spacing.of(context).spaces.semiBig,
                right: Spacing.of(context).spaces.semiBig,
              ),
      actionsPadding: Spacing.of(context).insets.exceptBottom.normal.copyWith(
            left: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
            top: Spacing.of(context).spaces.extraSmall,
          ),
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildCloseButton(),
      ];

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget buildContent() {
    ScrollController contentController = ScrollController();

    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: contentController,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (1 / 3),
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildStatusIndicator(),
              const SizedBox(height: 12),
              buildServerUrlField(),
              const SizedBox(height: 12),
              buildUsernameField(),
              const SizedBox(height: 12),
              buildPasswordField(),
              const SizedBox(height: 16),
              buildConnectButton(),
              if (_isLoggedIn) ...[
                const SizedBox(height: 8),
                buildDisconnectButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Shows whether the user is currently connected to a Jellyfin server.
  Widget buildStatusIndicator() {
    return Row(
      children: [
        Icon(
          _isLoggedIn ? Icons.check_circle : Icons.cancel,
          color: _isLoggedIn ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          _isLoggedIn ? 'Connected' : 'Not connected',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _isLoggedIn ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget buildServerUrlField() {
    return TextField(
      enabled: !_isLoading,
      controller: _serverUrlController,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Server URL',
        hintText: 'http://192.168.1.100:8096',
      ),
    );
  }

  Widget buildUsernameField() {
    return TextField(
      enabled: !_isLoading,
      controller: _usernameController,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Username',
      ),
    );
  }

  Widget buildPasswordField() {
    return TextField(
      enabled: !_isLoading,
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Password',
      ),
    );
  }

  Widget buildConnectButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _connect,
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Connect'),
    );
  }

  Widget buildDisconnectButton() {
    return OutlinedButton(
      onPressed: _isLoading ? null : _disconnect,
      child: const Text('Disconnect'), // ignore: prefer_const_constructors
    );
  }

  Future<void> _connect() async {
    final serverUrl = _serverUrlController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _source.connectToServer(serverUrl, username, password);

      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connected to Jellyfin successfully.')),
        );
      }
    } on Exception catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isLoading = true);

    try {
      await _source.disconnect();
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      _usernameController.clear();
      _passwordController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disconnected from Jellyfin.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error disconnecting: $e')),
        );
      }
    }
  }
}
