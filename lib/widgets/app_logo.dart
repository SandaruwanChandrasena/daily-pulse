import 'package:flutter/material.dart';

/// The "Daily Pulse" logo text: "Daily" in dark, "Pulse" in red.
class AppLogo extends StatelessWidget {
  final double fontSize;

  const AppLogo({super.key, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
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