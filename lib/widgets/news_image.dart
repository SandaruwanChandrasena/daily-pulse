import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/source_style.dart';

/// News image with a loading box. If there is no image (or it fails),
/// it shows a colored box with the short source name, like "WSJ".
/// If [aspectRatio] is null, the image fills the space its parent gives it.
class NewsImage extends StatelessWidget {
  final String imageUrl;
  final String sourceName;
  final double? aspectRatio;

  const NewsImage({
    super.key,
    required this.imageUrl,
    this.sourceName = '',
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final image = imageUrl.isEmpty
        ? _placeholder()
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
              errorWidget: (context, url, error) => _placeholder(),
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

  /// The "no image" box: source color gradient + short source name.
  Widget _placeholder() {
    final shortName = sourceShortName(sourceName);
    final baseColor = sourceColor(sourceName);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 90.0;
        final fontSize = (height * 0.3).clamp(20.0, 56.0);

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, Color.lerp(baseColor, Colors.black, 0.35)!],
            ),
          ),
          child: shortName.isEmpty
              ? const Icon(Icons.newspaper, size: 32, color: Colors.white70)
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    shortName,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
        );
      },
    );
  }
}