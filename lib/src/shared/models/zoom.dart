import 'package:flutter/rendering.dart';

enum PageZoom { fitted, zoomed }

/// Above this scale a page counts as zoomed; just above fitted, so float
/// noise at the end of a zoom-out does not keep it zoomed.
const double zoomedAboveScale = 1.01;

/// Where a pinch that took over from a swipe started.
typedef PinchStart = ({double span, Offset focal});

abstract final class PageZoomMath {
  static bool isZoomed(Matrix4 transform) =>
      transform.getMaxScaleOnAxis() > zoomedAboveScale;

  /// Zoomed in by [scale], keeping [focal] fixed on screen.
  static Matrix4 zoomedInAt({required Offset focal, required double scale}) {
    return Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(focal.dx * (1 - scale), focal.dy * (1 - scale), 0);
  }

  /// Clamps a two-finger pinch translation so the zoomed child keeps
  /// covering [viewportSize].
  static Matrix4 clampedPinch({
    required PinchStart start,
    required Offset currentFocal,
    required double currentSpan,
    required Size viewportSize,
    required double minScale,
    required double maxScale,
  }) {
    final scale = (currentSpan / start.span).clamp(minScale, maxScale);
    final dx = (currentFocal.dx - start.focal.dx * scale).clamp(
      viewportSize.width * (1 - scale),
      0.0,
    );
    final dy = (currentFocal.dy - start.focal.dy * scale).clamp(
      viewportSize.height * (1 - scale),
      0.0,
    );

    return Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(dx, dy, 0);
  }
}
