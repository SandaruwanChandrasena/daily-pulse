import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// News image with a loading spinner and a grey fallback box.
class NewsImage extends StatelessWidget {
  final String imageUrl;

  const NewsImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: imageUrl.isEmpty
          ? _placeholder(colors)
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colors.surfaceContainerHighest,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => _placeholder(colors),
            ),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}