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
        : LayoutBuilder(
            builder: (context, constraints) => CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              memCacheWidth: _pixelWidth(context, constraints),
              fadeInDuration: const Duration(milliseconds: 250),
              fadeOutDuration: const Duration(milliseconds: 150),
              placeholder: (context, url) =>
                  Container(color: colors.surfaceContainerHighest),
              errorWidget: (context, url, error) => _placeholder(colors),
            ),
          );

    if (aspectRatio == null) return image;
    return AspectRatio(aspectRatio: aspectRatio!, child: image);
  }

  /// Keeps only a small copy in memory: the size of the box on screen.
  /// A 2000 px photo shown in a 110 px box does not need 2000 px.
  int? _pixelWidth(BuildContext context, BoxConstraints constraints) {
    if (!constraints.maxWidth.isFinite) return null;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return (constraints.maxWidth * ratio).round();
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