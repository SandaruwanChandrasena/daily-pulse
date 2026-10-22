import 'package:flutter/material.dart';

/// #Topic chips. Tap a chip to search that topic.
/// [scrollable] = one sideways row. Otherwise the chips wrap to new lines.
class TopicChips extends StatelessWidget {
  final List<String> topics;
  final ValueChanged<String> onTap;
  final Set<String> hotTopics;
  final bool scrollable;

  const TopicChips({
    super.key,
    required this.topics,
    required this.onTap,
    this.hotTopics = const {},
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final chips = [for (final topic in topics) _buildChip(topic, colors)];

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            for (final chip in chips)
              Padding(padding: const EdgeInsets.only(right: 8), child: chip),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  /// "Sri Lanka" shows as "#SriLanka". Hot topics get a light red background.
  Widget _buildChip(String topic, ColorScheme colors) {
    final isHot = hotTopics.contains(topic);

    return ActionChip(
      label: Text('#${topic.replaceAll(' ', '')}'),
      labelStyle: TextStyle(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: isHot
          ? colors.primaryContainer.withValues(alpha: 0.5)
          : colors.surfaceContainer,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      onPressed: () => onTap(topic),
    );
  }
}