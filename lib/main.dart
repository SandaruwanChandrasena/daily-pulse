import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/bookmark_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/news_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/app_logo.dart';

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
        ChangeNotifierProvider(create: (_) => OnboardingProvider()..load()),
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
      home: const _StartScreen(),
    );
  }
}

/// Picks the first screen: the welcome screens (first time) or the app.
class _StartScreen extends StatelessWidget {
  const _StartScreen();

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();

    if (!onboarding.isReady) {
      return const Scaffold(body: Center(child: AppLogo(fontSize: 36)));
    }
    return onboarding.isDone ? const MainShell() : const OnboardingScreen();
  }
}