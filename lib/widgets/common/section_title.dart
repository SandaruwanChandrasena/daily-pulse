import 'package:flutter/material.dart';

/// A bold section title, like "Latest News".
/// It can show a small button on the right, like "See All".
class SectionTitle extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 28, hasAction ? 4 : 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (hasAction)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}