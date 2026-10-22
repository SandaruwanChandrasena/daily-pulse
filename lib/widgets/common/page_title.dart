import 'package:flutter/material.dart';

/// A big bold title for the top of a tab, like "Explore" or "Search".
class PageTitle extends StatelessWidget {
  final String text;

  const PageTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}