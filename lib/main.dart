import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/navigation_provider.dart';
import 'providers/news_provider.dart';
import 'providers/search_provider.dart';
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
      ],
      child: const DailyPulseApp(),
    ),
  );
}

class DailyPulseApp extends StatelessWidget {
  const DailyPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainShell(),
    );
  }
}