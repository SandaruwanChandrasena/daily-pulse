import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/bookmark_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/news_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(
    // Makes every provider available to all screens below it.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()..loadNews()),
        ChangeNotifierProvider(
          create: (_) => SearchProvider()..loadHistory(),
        ),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
      ],
      child: const DailyPulseApp(),
    ),
  );
}

class DailyPulseApp extends StatelessWidget {
  const DailyPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      title: 'Daily Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const MainShell(),
    );
  }
}