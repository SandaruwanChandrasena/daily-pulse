import 'package:flutter/material.dart';

/// All app colors and styles in one place (red Daily Pulse look).
/// [light] and [dark] share the same styles, only the colors change.
class AppTheme {
  static const Color brandRed = Color(0xFFD32F2F);
  static const Color brandRedLight = Color(0xFFEF5350);

  static ThemeData light() {
    return _build(
      ColorScheme.fromSeed(
        seedColor: brandRed,
        primary: brandRed,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData dark() {
    return _build(
      ColorScheme.fromSeed(
        seedColor: brandRed,
        brightness: Brightness.dark,
        primary: brandRedLight,
        onPrimary: Colors.white,
        surface: const Color(0xFF121212),
      ),
    );
  }

  /// Builds the theme from a color set, so light and dark look the same.
  static ThemeData _build(ColorScheme colors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 3,
        shadowColor: Colors.black26,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.primary : colors.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colors.primary : colors.onSurfaceVariant,
          );
        }),
      ),
    );
  }
}