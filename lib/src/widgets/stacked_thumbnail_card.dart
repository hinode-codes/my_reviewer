import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';

class StackedThumbnailCard extends StatelessWidget {
  final List<String> imagePaths;
  final double? width;
  final double? height;
  final String? heroPrefix;
  final double cardAspectRatio; // Document aspect ratio (width / height)

  const StackedThumbnailCard({
    super.key,
    required this.imagePaths,
    this.width,
    this.height,
    this.heroPrefix,
    this.cardAspectRatio = 0.707, // Standard A4 / Document portrait ratio
  });

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return _buildPlaceholder();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availWidth = width ?? constraints.maxWidth;
        final availHeight = height ?? constraints.maxHeight;

        // Reserve just enough margin (8px) for rotation & translation overflow
        const overflowMargin = 8.0;
        final safeWidth = (availWidth - overflowMargin).clamp(
          0.0,
          double.infinity,
        );
        final safeHeight = (availHeight - overflowMargin).clamp(
          0.0,
          double.infinity,
        );

        // Maximize card height to fill available vertical space first
        double cardHeight = safeHeight;
        double cardWidth = cardHeight * cardAspectRatio;

        // Fallback constraint check if width is narrower than needed
        if (cardWidth > safeWidth) {
          cardWidth = safeWidth;
          cardHeight = cardWidth / cardAspectRatio;
        }

        // Clamp translation offsets so cards don't spread out too far at larger sizes
        final offsetX = (cardWidth * 0.08).clamp(4.0, 8.0);
        final offsetY = (cardHeight * 0.04).clamp(2.0, 6.0);

        final displayPaths = imagePaths.take(3).toList();
        final count = displayPaths.length;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: List.generate(count, (index) {
              double angle = 0.0;
              Offset translation = Offset.zero;

              if (count == 3) {
                if (index == 0) {
                  angle = -0.1;
                  translation = Offset(-offsetX, offsetY);
                } else if (index == 1) {
                  angle = 0.08;
                  translation = Offset(offsetX, offsetY);
                } else {
                  angle = 0.0;
                  translation = Offset.zero;
                }
              } else if (count == 2) {
                if (index == 0) {
                  angle = -0.1;
                  translation = Offset(-offsetX, offsetY);
                } else {
                  angle = 0.0;
                  translation = Offset.zero;
                }
              }

              final imagePath = displayPaths[index];
              final heroTag = heroPrefix != null
                  ? '${heroPrefix}_$imagePath'
                  : imagePath;

              return Transform.translate(
                offset: translation,
                child: Transform.rotate(
                  angle: angle,
                  child: Hero(
                    tag: heroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            cacheWidth: DocsUiConstants.thumbnailCacheWidth,
                            errorBuilder: (_, _, _) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: width ?? constraints.maxWidth,
          height: height ?? constraints.maxHeight,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Icon(Icons.folder_open, size: 40, color: Colors.grey),
        );
      },
    );
  }
}
