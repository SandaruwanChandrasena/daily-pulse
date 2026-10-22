import 'package:flutter/material.dart';

import '../../models/article.dart';
import '../../utils/date_helper.dart';

/// "Source • time ago" on one line. A long source name is cut ("…"),
/// but the time is always shown in full.
class SourceAndTime extends StatelessWidget {
  final Article article;
  final TextStyle? style;

  const SourceAndTime({super.key, required this.article, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            article.sourceName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        Text(' • ${timeAgo(article.publishedAt)}', maxLines: 1, style: style),
      ],
    );
  }
}