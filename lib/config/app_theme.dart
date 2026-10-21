import 'package:flutter/material.dart';

/// All app colors and styles in one place (red Daily Pulse look).
class AppTheme {
  static const Color brandRed = Color(0xFFD32F2F);

  static ThemeData light() {
    final colors = ColorScheme.fromSeed(
      seedColor: brandRed,
      primary: brandRed,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 3,
        shadowColor: Colors.black26,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? brandRed : Colors.grey.shade600,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? brandRed : Colors.grey.shade600,
          );
        }),
      ),
    );
  }
}