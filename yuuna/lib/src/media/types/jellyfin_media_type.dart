import 'package:flutter/material.dart';

import '../../../pages.dart';
import '../media_type.dart';

/// A dedicated media type for Jellyfin that appears as its own tab
/// in the bottom navigation bar. Shows the [JellyfinLibraryPage]
/// directly for a Moonfin-style browsing experience.
class JellyfinMediaType extends MediaType {
  JellyfinMediaType._privateConstructor()
      : super(
          uniqueKey: 'jellyfin',
          icon: Icons.live_tv,
          outlinedIcon: Icons.live_tv_outlined,
        );

  /// The singleton instance of this media type.
  static final JellyfinMediaType instance =
      JellyfinMediaType._privateConstructor();

  @override
  Widget get home => const _JellyfinHomeTab();
}

/// The body content for the Jellyfin tab in the main menu.
class _JellyfinHomeTab extends BasePage {
  const _JellyfinHomeTab();

  @override
  BasePageState<_JellyfinHomeTab> createState() => _JellyfinHomeTabState();
}

class _JellyfinHomeTabState extends BasePageState<_JellyfinHomeTab> {
  @override
  Widget build(BuildContext context) => const JellyfinLibraryPage();
}
