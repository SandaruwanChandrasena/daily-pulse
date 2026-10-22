import 'package:flutter/material.dart';

/// A full-width bar with an icon and a short message (offline, notes, errors).
class InfoBar extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  const InfoBar({
    super.key,
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: foreground, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}