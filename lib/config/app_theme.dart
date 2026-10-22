import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All app colors, fonts and styles in one place (red Daily Pulse look).
/// [light] and [dark] share the same styles, only the colors change.
/// Fonts: Archivo (bold block letters) for titles, Inter for reading text.
class AppTheme {
  static const Color brandRed = Color(0xFFD32F2F);
  static const Color brandRedLight = Color(0xFFEF5350);
  static const Color highlightBlue = Color(0xFF1E88E5);

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
    final theme = ThemeData(
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
    return theme.copyWith(textTheme: _textTheme(theme.textTheme));
  }

  /// Titles use Archivo. Body text uses Inter with more line height.
  static TextTheme _textTheme(TextTheme base) {
    final body = GoogleFonts.interTextTheme(base);
    TextStyle? heading(TextStyle? style) => GoogleFonts.archivo(
      textStyle: style,
    );

    return body.copyWith(
      displayLarge: heading(base.displayLarge),
      displayMedium: heading(base.displayMedium),
      displaySmall: heading(base.displaySmall),
      headlineLarge: heading(base.headlineLarge),
      headlineMedium: heading(base.headlineMedium),
      headlineSmall: heading(base.headlineSmall),
      titleLarge: heading(base.titleLarge),
      titleMedium: heading(base.titleMedium),
      titleSmall: heading(base.titleSmall),
      bodyLarge: body.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: body.bodyMedium?.copyWith(height: 1.45),
      bodySmall: body.bodySmall?.copyWith(height: 1.4),
    );
  }
}