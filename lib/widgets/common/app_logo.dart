import 'package:flutter/material.dart';

/// The "Daily Pulse" logo text: "Daily" in dark, "Pulse" in red.
class AppLogo extends StatelessWidget {
  final double fontSize;

  const AppLogo({super.key, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = theme.textTheme.headlineSmall!.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.2,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Daily',
            style: style.copyWith(color: colors.onSurface),
          ),
          TextSpan(
            text: 'Pulse',
            style: style.copyWith(color: colors.primary),
          ),
        ],
      ),
    );
  }
}