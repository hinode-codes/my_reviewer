import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/models/zoom.dart';
import 'package:my_reviewer/src/shared/ui/zoom/zoomable_page.dart';

typedef ZoomablePageBuilder = Widget Function(
  BuildContext context,
  int index,
  GlobalKey<ZoomablePageState> zoomKey,
);

/// A [PageView.builder] that:
/// 1. Locks horizontal paging while the active page is zoomed.
/// 2. Hands off a second finger landing mid-swipe to [ZoomablePageState].
/// 3. Excludes off-screen neighbor pages from the semantics tree so screen
///    readers never focus invisible pages, while supporting semantic page turns.
class ZoomablePageView extends StatefulWidget {
  const ZoomablePageView({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.currentIndex,
    required this.zoom,
    required this.onPageChanged,
    required this.itemBuilder,
    this.pageAnnouncementBuilder,
  });

  final PageController controller;
  final int itemCount;
  final int currentIndex;
  final PageZoom zoom;
  final ValueChanged<int> onPageChanged;
  final ZoomablePageBuilder itemBuilder;

  /// Optional announcement when turning pages (e.g., "Page 2 of 5").
  final String Function(int index, int total)? pageAnnouncementBuilder;

  @override
  State<ZoomablePageView> createState() => ZoomablePageViewState();
}

class ZoomablePageViewState extends State<ZoomablePageView> {
  final Map<int, GlobalKey<ZoomablePageState>> _pageKeys = {};
  final Map<int, Offset> _pointers = {};
  ZoomablePageState? _pinchingPage;

  GlobalKey<ZoomablePageState> _keyFor(int index) =>
      _pageKeys.putIfAbsent(index, () => GlobalKey<ZoomablePageState>());

  /// Exposes the active page's [ZoomablePageState] so an AppBar zoom button
  /// can trigger [zoomIn] / [resetZoom] for motor-impaired users.
  ZoomablePageState? get currentZoomablePage =>
      _pageKeys[widget.currentIndex]?.currentState;

  bool get _isPageTurning =>
      widget.controller.hasClients &&
      widget.controller.position.isScrollingNotifier.value;

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length != 2 || !_isPageTurning) {
      return;
    }

    final page = currentZoomablePage;
    if (page != null && page.startTakenOverPinch(_pointers.values)) {
      _pinchingPage = page;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) {
      return;
    }

    _pointers[event.pointer] = event.localPosition;
    _pinchingPage?.followTakenOverPinch(_pointers.values);
  }

  void _onPointerGone(PointerEvent event) {
    _pointers.remove(event.pointer);

    if (_pointers.length < 2) {
      _pinchingPage?.endTakenOverPinch();
      _pinchingPage = null;
    }
  }

  void _goToPage(int index) {
    if (index < 0 ||
        index >= widget.itemCount ||
        !widget.controller.hasClients) {
      return;
    }
    widget.controller.animateToPage(
      index,
      duration: AnimationConstants.sm,
      curve: Curves.easeOut,
    );
  }

  void _handlePageChanged(int index) {
    widget.onPageChanged(index);

    final announcement = widget.pageAnnouncementBuilder?.call(
      index,
      widget.itemCount,
    );
    if (announcement != null) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        announcement,
        Directionality.of(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrevious =
        widget.zoom == PageZoom.fitted && widget.currentIndex > 0;
    final canGoNext =
        widget.zoom == PageZoom.fitted &&
        widget.currentIndex < widget.itemCount - 1;

    return Semantics(
      // Enables three-finger / accessibility scroll gestures to turn pages.
      onScrollRight: canGoPrevious
          ? () => _goToPage(widget.currentIndex - 1)
          : null,
      onScrollLeft: canGoNext ? () => _goToPage(widget.currentIndex + 1) : null,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerGone,
        onPointerCancel: _onPointerGone,
        child: PageView.builder(
          controller: widget.controller,
          physics: switch (widget.zoom) {
            PageZoom.fitted => null,
            PageZoom.zoomed => const NeverScrollableScrollPhysics(),
          },
          itemCount: widget.itemCount,
          onPageChanged: _handlePageChanged,
          itemBuilder: (context, index) {
            final isCurrent = index == widget.currentIndex;

            return ExcludeSemantics(
              excluding: !isCurrent,
              child: IndexedSemantics(
                index: index,
                child: widget.itemBuilder(context, index, _keyFor(index)),
              ),
            );
          },
        ),
      ),
    );
  }
}
