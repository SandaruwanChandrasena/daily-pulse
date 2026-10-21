import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// News image with a loading box and a grey fallback.
/// If [aspectRatio] is null, the image fills the space its parent gives it.
class NewsImage extends StatelessWidget {
  final String imageUrl;
  final double? aspectRatio;

  const NewsImage({
    super.key,
    required this.imageUrl,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final image = imageUrl.isEmpty
        ? _placeholder(colors)
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) =>
                Container(color: colors.surfaceContainerHighest),
            errorWidget: (context, url, error) => _placeholder(colors),
          );

    if (aspectRatio == null) return image;
    return AspectRatio(aspectRatio: aspectRatio!, child: image);
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 32,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}