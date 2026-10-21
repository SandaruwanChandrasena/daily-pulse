import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_info.dart';
import '../config/app_theme.dart';
import '../providers/news_provider.dart';
import '../providers/search_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/confirm_dialog.dart';
import '../widgets/app_logo.dart';
import '../widgets/page_title.dart';
import '../widgets/section_title.dart';

/// Settings tab: app card, theme choice, clear data and about.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Reads the version from the app itself (it comes from pubspec.yaml).
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  void _showMessage(ScaffoldMessengerState messenger, String text) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _openLink(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('openLink error: $e');
    }
    if (!opened) _showMessage(messenger, 'Could not open the link.');
  }

  Future<void> _clearHistory() async {
    final search = context.read<SearchProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear search history?',
      message: 'Your recent searches will be removed.',
      confirmLabel: 'Clear',
    );
    if (!confirmed) return;

    search.clearHistory();
    _showMessage(messenger, 'Search history cleared');
  }

  Future<void> _clearCache() async {
    final news = context.read<NewsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear cached news?',
      message:
          'Offline news on this phone will be removed. '
          'Fresh news will load from the internet.',
      confirmLabel: 'Clear',
    );
    if (!confirmed) return;

    _showMessage(messenger, 'Cached news cleared');
    await news.clearCache();
  }

  void _showAbout(String version) {
    showAboutDialog(
      context: context,
      applicationName: AppInfo.name,
      applicationVersion: 'Version $version',
      applicationIcon: const _AppIcon(size: 48),
      applicationLegalese: '© 2026 ${AppInfo.developer}',
      children: const [
        SizedBox(height: 16),
        Text('News data from NewsAPI.org.'),
        SizedBox(height: 8),
        Text('Built with Flutter as a learning project.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    final historyCount = context.select<SearchProvider, int>(
      (search) => search.history.length,
    );

    return Scaffold(
      appBar: AppBar(title: const PageTitle('Settings'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const _AppCard(),
          const SectionTitle(text: 'Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SegmentedButton<ThemeMode>(
              expandedInsets: const EdgeInsets.symmetric(horizontal: 16),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('System'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  context.read<ThemeProvider>().setThemeMode(selection.first),
            ),
          ),
          const SectionTitle(text: 'Storage'),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Clear search history'),
            subtitle: Text(
              historyCount == 0
                  ? 'No recent searches'
                  : '$historyCount recent searches',
            ),
            enabled: historyCount > 0,
            onTap: _clearHistory,
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear cached news'),
            subtitle: const Text('Offline news saved on this phone'),
            onTap: _clearCache,
          ),
          const SectionTitle(text: 'About'),
          FutureBuilder<PackageInfo>(
            future: _packageInfo,
            builder: (context, snapshot) {
              final info = snapshot.data;
              final version = info == null
                  ? '...'
                  : '${info.version} (${info.buildNumber})';

              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Daily Pulse'),
                subtitle: Text('Version $version'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAbout(version),
              );
            },
          ),
          _LinkTile(
            icon: Icons.code,
            title: 'Source code on GitHub',
            subtitle: 'See how this app is built',
            onTap: () => _openLink(AppInfo.githubUrl),
          ),
          _LinkTile(
            icon: Icons.play_circle_outline,
            title: 'YouTube channel',
            subtitle: 'Videos about my coding projects',
            onTap: () => _openLink(AppInfo.youtubeUrl),
          ),
          _LinkTile(
            icon: Icons.newspaper,
            title: 'News data by NewsAPI.org',
            subtitle: 'newsapi.org',
            onTap: () => _openLink(AppInfo.newsApiUrl),
          ),
        ],
      ),
    );
  }
}

/// The card at the top: app icon, logo and tagline.
class _AppCard extends StatelessWidget {
  const _AppCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const _AppIcon(size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(fontSize: 22),
                const SizedBox(height: 4),
                Text(
                  AppInfo.tagline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small red square with a pulse icon, like the app icon.
class _AppIcon extends StatelessWidget {
  final double size;

  const _AppIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.brandRed,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.monitor_heart_outlined,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

/// A row that opens a web link in the browser.
class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: onTap,
    );
  }
}