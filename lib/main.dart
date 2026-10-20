import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/news_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    // Makes NewsProvider available to every screen below it.
    // "..loadTopHeadlines()" starts loading news as soon as the app opens.
    ChangeNotifierProvider(
      create: (_) => NewsProvider()..loadTopHeadlines(),
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}
