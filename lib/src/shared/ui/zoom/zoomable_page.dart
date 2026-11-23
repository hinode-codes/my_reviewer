import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/models/zoom.dart';

/// Pinch to zoom, drag to pan while zoomed, double-tap to zoom in on the
/// tapped spot or back out. Also exposes semantic zoom actions and
/// [zoomIn]/[resetZoom] helpers for accessible toolbar buttons.
class ZoomablePage extends StatefulWidget {
  const ZoomablePage({
    super.key,
    required this.isActive,
    required this.isZoomed,
    required this.onZoomChanged,
    required this.maxScale,
    required this.doubleTapScale,
    this.semanticLabel,
    this.zoomInLabel = 'Zoom in',
    this.zoomOutLabel = 'Reset zoom',
    required this.child,
  });

  final bool isActive;
  final bool isZoomed;
  final ValueChanged<PageZoom> onZoomChanged;
  final double maxScale;
  final double doubleTapScale;

  /// Describes the page content (e.g. "Page 2 of 5: Receipt").
  final String? semanticLabel;

  /// Localized action label for zooming in via screen reader actions.
  final String zoomInLabel;

  /// Localized action label for resetting zoom via screen reader actions.
  final String zoomOutLabel;

  final Widget child;

  @override
  State<ZoomablePage> createState() => ZoomablePageState();
}

class ZoomablePageState extends State<ZoomablePage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _doubleTap;

  Animation<Matrix4>? _doubleTapZoom;
  Offset? _doubleTapPosition;
  PinchStart? _takenOverPinch;
  PageZoom _lastReportedZoom = PageZoom.fitted;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransformChanged);
    _doubleTap = AnimationController(
      vsync: this,
      duration: AnimationConstants.sm,
    )..addListener(_onDoubleTapTick);
  }

  @override
  void dispose() {
    _doubleTap.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    if (!widget.isActive || _takenOverPinch != null) {
      return;
    }
    _reportZoom();
  }

  void _reportZoom() {
    final next = PageZoomMath.isZoomed(_transform.value)
        ? PageZoom.zoomed
        : PageZoom.fitted;

    if (next == _lastReportedZoom) {
      return;
    }

    _lastReportedZoom = next;
    widget.onZoomChanged(next);

    // Announce state transitions to screen readers without spamming ticks.
    if (widget.isActive) {
      final announcement = switch (next) {
        PageZoom.zoomed => widget.zoomInLabel,
        PageZoom.fitted => widget.zoomOutLabel,
      };
      SemanticsService.sendAnnouncement(
        View.of(context),
        announcement,
        Directionality.of(context),
      );
    }
  }

  /// Programmatically zooms in on the center (or [focal]) for accessible controls.
  void zoomIn([Offset? focal]) {
    final size = context.size;
    if (size == null) {
      return;
    }

    _animateTransformTo(
      PageZoomMath.zoomedInAt(
        focal: focal ?? size.center(Offset.zero),
        scale: widget.doubleTapScale,
      ),
    );
  }

  /// Programmatically resets zoom back to fitted.
  void resetZoom() {
    _animateTransformTo(Matrix4.identity());
  }

  void toggleZoom([Offset? focal]) {
    if (PageZoomMath.isZoomed(_transform.value)) {
      resetZoom();
    } else {
      zoomIn(focal);
    }
  }

  void _animateTransformTo(Matrix4 target) {
    _doubleTapZoom = Matrix4Tween(
      begin: _transform.value,
      end: target,
    ).animate(CurvedAnimation(parent: _doubleTap, curve: Curves.easeOut));
    _doubleTap.forward(from: 0);
  }

  bool startTakenOverPinch(Iterable<Offset> fingers) {
    final [first, second, ...] = fingers.toList();
    final span = (first - second).distance;

    if (span == 0) {
      return false;
    }

    _takenOverPinch = (span: span, focal: Offset.lerp(first, second, 0.5)!);
    _lastReportedZoom = PageZoom.zoomed;
    widget.onZoomChanged(PageZoom.zoomed);

    return true;
  }

  void followTakenOverPinch(Iterable<Offset> fingers) {
    final start = _takenOverPinch;
    final size = context.size;

    if (start == null || size == null || fingers.length < 2) {
      return;
    }

    final [first, second, ...] = fingers.toList();
    _transform.value = PageZoomMath.clampedPinch(
      start: start,
      currentFocal: Offset.lerp(first, second, 0.5)!,
      currentSpan: (first - second).distance,
      viewportSize: size,
      minScale: 1.0,
      maxScale: widget.maxScale,
    );
  }

  void endTakenOverPinch() {
    _takenOverPinch = null;
    _reportZoom();
  }

  void _onDoubleTapTick() {
    final zoom = _doubleTapZoom;
    if (zoom != null) {
      _transform.value = zoom.value;
    }
  }

  void _onDoubleTap() {
    toggleZoom(_doubleTapPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      image: true,
      // Exposes zoom toggle in TalkBack/VoiceOver custom actions menu
      // and supports double-tap activation via assistive tech.
      customSemanticsActions: {
        CustomSemanticsAction(
          label: widget.isZoomed ? widget.zoomOutLabel : widget.zoomInLabel,
        ): toggleZoom,
      },
      child: GestureDetector(
        excludeFromSemantics: true,
        onDoubleTapDown: (details) =>
            _doubleTapPosition = details.localPosition,
        onDoubleTap: _onDoubleTap,
        child: InteractiveViewer(
          transformationController: _transform,
          minScale: 1,
          maxScale: widget.maxScale,
          panEnabled: widget.isActive && widget.isZoomed,
          child: widget.child,
        ),
      ),
    );
  }
}
