import 'dart:io';
import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';
import 'package:my_reviewer/src/constants/stack_constants.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs/page_viewer_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/models/ui_sound.dart';
import 'package:my_reviewer/src/utils/hero_tags.dart';
import 'package:my_reviewer/src/widgets/common/misc/thumbnail/flight_sound.dart';
import 'package:my_reviewer/src/widgets/common/misc/thumbnail/page_aspect_builder.dart';
import 'package:my_reviewer/src/widgets/common/misc/thumbnail/thumbnail_image.dart';
import 'package:provider/provider.dart';

/// A group's pages, full screen, one at a time. The tapped grid tile flies
/// in as a hero, and the page showing on exit flies back to its tile.
class DocsPageViewerScreen extends StatelessWidget {
  const DocsPageViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<DocsPageViewerController, ItemsStatus>(
      (c) => c.status,
    );

    return switch (status) {
      ItemsStatus.ready => const _PageViewer(),
      ItemsStatus.failed => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(t.common.status.failed)),
      ),
      // Only from a deep link: opened from the grid, the pages come with
      // the route and the viewer starts ready.
      ItemsStatus.loading => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator.adaptive(
            semanticsLabel: t.common.status.loading,
          ),
        ),
      ),
    };
  }
}

class _PageViewer extends StatefulWidget {
  const _PageViewer();

  @override
  State<_PageViewer> createState() => _PageViewerState();
}

/// Stateful to own the PageController (a widget-side object that must be
/// disposed) and to watch raw pointers for late pinches. Which page shows
/// and whether it is zoomed live in the controller.
class _PageViewerState extends State<_PageViewer> {
  late final PageController _pageController;

  /// Lets the viewer hand a late pinch to the page it belongs to.
  final Map<int, GlobalKey<_ZoomablePageState>> _pageKeys = {};

  /// Fingers on the viewer, by pointer id, in viewer coordinates.
  final Map<int, Offset> _pointers = {};

  /// The page zooming from a pinch that started as a swipe, if any.
  _ZoomablePageState? _pinchingPage;

  @override
  void initState() {
    super.initState();

    // Read once here, not in build: provider forbids `read` during build,
    // and a late initializer would first run there.
    _pageController = PageController(
      initialPage: context.read<DocsPageViewerController>().currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  GlobalKey<_ZoomablePageState> _keyFor(int index) =>
      _pageKeys.putIfAbsent(index, () => GlobalKey<_ZoomablePageState>());

  bool get _isPageTurning =>
      _pageController.hasClients &&
      _pageController.position.isScrollingNotifier.value;

  // A pinch whose fingers land together goes to the page's
  // InteractiveViewer. One whose first finger has already started turning
  // the page cannot: the page view won that finger in the gesture arena.
  // A Listener sees every pointer whoever wins it, so when a second finger
  // lands mid-swipe the viewer stops the swipe and the page zooms itself.

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length != 2 || !_isPageTurning) {
      return;
    }

    final index = context.read<DocsPageViewerController>().currentIndex;
    final page = _pageKeys[index]?.currentState;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final docs = context
        .select<DocsPageViewerController, List<ScannedDocumentModel>>(
          (c) => c.docs,
        );
    final currentIndex = context.select<DocsPageViewerController, int>(
      (c) => c.currentIndex,
    );
    final zoom = context.select<DocsPageViewerController, PageZoom>(
      (c) => c.zoom,
    );

    return Scaffold(
      backgroundColor: colorScheme.scrim,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colorScheme.scrim.withValues(alpha: 0),
        foregroundColor: colorScheme.onPrimary,
        title: Text(docs[currentIndex].name),
      ),
      body: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerGone,
        onPointerCancel: _onPointerGone,
        child: PageView.builder(
          controller: _pageController,
          // A zoomed page owns horizontal drags for panning; turning pages
          // resumes once it is zoomed back out.
          physics: switch (zoom) {
            PageZoom.fitted => null,
            PageZoom.zoomed => const NeverScrollableScrollPhysics(),
          },
          itemCount: docs.length,
          onPageChanged: (index) =>
              context.read<DocsPageViewerController>().showPage(index),
          itemBuilder: (context, index) => _ViewerPage(
            zoomKey: _keyFor(index),
            doc: docs[index],
            isCurrent: index == currentIndex,
          ),
        ),
      ),
    );
  }
}

class _ViewerPage extends StatelessWidget {
  const _ViewerPage({
    required this.zoomKey,
    required this.doc,
    required this.isCurrent,
  });

  final GlobalKey<_ZoomablePageState> zoomKey;
  final ScannedDocumentModel doc;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    // PageView keeps neighbouring pages built offscreen; only the page
    // showing may fly, or neighbours would fly in from off screen. HeroMode
    // switches that without changing the tree, so a page keeps its state
    // when it becomes the current one.
    return HeroMode(
      enabled: isCurrent,
      // The whole screen is the hero, so the page lands full screen and can
      // be zoomed and panned edge to edge.
      child: Hero(
        tag: pageHeroTag(doc.groupId, doc.absoluteFilePath),
        transitionOnUserGestures: true,
        flightShuttleBuilder: _pageShuttle(doc.absoluteFilePath),
        child: _ZoomablePage(
          key: zoomKey,
          isCurrent: isCurrent,
          child: SizedBox.expand(
            child: _FullPageImage(path: doc.absoluteFilePath),
          ),
        ),
      ),
    );
  }
}

/// Above this scale a page counts as zoomed; just above fitted, so float
/// noise at the end of a zoom-out does not keep it zoomed.
const double _zoomedAboveScale = 1.01;

/// Where a pinch that took over from a swipe started.
typedef _PinchStart = ({double span, Offset focal});

/// Pinch to zoom, drag to pan while zoomed, double-tap to zoom in on the
/// tapped spot or back out. Also zooms from a pinch the viewer hands over
/// when it started as a swipe (see `_PageViewerState`).
class _ZoomablePage extends StatefulWidget {
  const _ZoomablePage({
    super.key,
    required this.isCurrent,
    required this.child,
  });

  final bool isCurrent;
  final Widget child;

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

/// Stateful to own the TransformationController and the double-tap
/// animation, both widget-side objects that must be disposed. Whether the
/// page is zoomed is reported to the controller, which the page view reads.
class _ZoomablePageState extends State<_ZoomablePage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _doubleTap;

  Animation<Matrix4>? _doubleTapZoom;
  Offset? _doubleTapPosition;

  _PinchStart? _takenOverPinch;

  @override
  void initState() {
    super.initState();

    _transform.addListener(_onTransformChanged);
    _doubleTap = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    )..addListener(_onDoubleTapTick);
  }

  @override
  void dispose() {
    _doubleTap.dispose();
    _transform.dispose();
    super.dispose();
  }

  bool get _isZoomed =>
      _transform.value.getMaxScaleOnAxis() > _zoomedAboveScale;

  void _onTransformChanged() {
    // Only the page showing decides whether pages can turn, and a pinch
    // that took over keeps them locked until its fingers lift.
    if (!widget.isCurrent || _takenOverPinch != null) {
      return;
    }

    _reportZoom();
  }

  void _reportZoom() {
    context.read<DocsPageViewerController>().setZoom(
      _isZoomed ? PageZoom.zoomed : PageZoom.fitted,
    );
  }

  /// Starts zooming from two fingers that began as a swipe. False when they
  /// are on the same spot, which gives no span to scale from.
  bool startTakenOverPinch(Iterable<Offset> fingers) {
    final [first, second, ...] = fingers.toList();
    final span = (first - second).distance;

    if (span == 0) {
      return false;
    }

    _takenOverPinch = (span: span, focal: Offset.lerp(first, second, 0.5)!);

    // Locks the page view, which also cancels its drag; the page settles
    // back to this one while the fingers zoom it.
    context.read<DocsPageViewerController>().setZoom(PageZoom.zoomed);

    return true;
  }

  /// Scales about where the pinch started, following the fingers. Pages
  /// only turn while fitted, so the pinch always starts from fitted: a
  /// point p lands on p * scale + offset.
  void followTakenOverPinch(Iterable<Offset> fingers) {
    final start = _takenOverPinch;
    final size = context.size;

    if (start == null || size == null || fingers.length < 2) {
      return;
    }

    final [first, second, ...] = fingers.toList();
    final focal = Offset.lerp(first, second, 0.5)!;
    final scale = ((first - second).distance / start.span).clamp(
      1.0,
      DocsUiConstants.viewerMaxScale,
    );

    // Keep the page covering the screen, as InteractiveViewer would.
    final dx = (focal.dx - start.focal.dx * scale).clamp(
      size.width * (1 - scale),
      0.0,
    );
    final dy = (focal.dy - start.focal.dy * scale).clamp(
      size.height * (1 - scale),
      0.0,
    );

    _transform.value = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(dx, dy, 0);
  }

  /// The fingers lifted: pages turn again if the pinch ended fitted.
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
    final size = context.size;

    if (size == null) {
      return;
    }

    final end = _isZoomed
        ? Matrix4.identity()
        : _zoomedInAt(_doubleTapPosition ?? size.center(Offset.zero));

    _doubleTapZoom = Matrix4Tween(begin: _transform.value, end: end).animate(
      CurvedAnimation(parent: _doubleTap, curve: Curves.easeOut),
    );
    _doubleTap.forward(from: 0);
  }

  /// Zoomed in by the double-tap scale, keeping [focal] where it is on
  /// screen. From fitted, a point p lands on p * scale + offset, so the
  /// offset that keeps it in place is p * (1 - scale).
  Matrix4 _zoomedInAt(Offset focal) {
    const scale = DocsUiConstants.viewerDoubleTapScale;

    return Matrix4.diagonal3Values(scale, scale, 1)..setTranslationRaw(
      focal.dx * (1 - scale),
      focal.dy * (1 - scale),
      0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final zoom = context.select<DocsPageViewerController, PageZoom>(
      (c) => c.zoom,
    );

    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapPosition = details.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transform,
        // Never smaller than fitted: there is nothing to see beyond the page.
        minScale: 1,
        maxScale: DocsUiConstants.viewerMaxScale,
        // Fitted, a one-finger drag belongs to the page view, to turn pages.
        panEnabled: widget.isCurrent && zoom == PageZoom.zoomed,
        child: widget.child,
      ),
    );
  }
}

/// A page lifting to full screen, and settling back into the grid.
const FlightSounds _pageSounds = (
  push: UiSound.pageOpen,
  pop: UiSound.pageClose,
);

/// Flies one page image between the grid's card and the full screen,
/// fading the card's frame (corners, border, shadow) out on the way in and
/// back in on the way out.
///
/// The flying page changes shape as it goes: the grid's uniform card shape
/// at one end, the page's real shape (as the viewer shows it) at the other,
/// with the image covering it throughout. So it matches the tile exactly on
/// take-off and the viewer exactly on landing, even for a receipt.
///
/// Used both ways: on push the viewer is the destination, whose shuttle
/// wins; on pop the grid tile has none, so the viewer's is used again.
HeroFlightShuttleBuilder _pageShuttle(String path) {
  return (flightContext, animation, direction, fromHeroContext, toHeroContext) {
    final colorScheme = Theme.of(flightContext).colorScheme;

    // Only the page showing flies (see HeroMode above), so this plays once.
    return FlightSound(
      sounds: _pageSounds,
      direction: direction,
      child: PageAspectBuilder(
      path: path,
      builder: (context, pageAspectRatio) => AnimatedBuilder(
        animation: animation,
        child: ThumbnailImage(path: path),
        builder: (context, image) {
          // The route animation is 0 at the grid and 1 in the viewer in
          // both directions.
          final t = animation.value;
          final frame = 1 - t;
          final radius = BorderRadius.circular(
            StackConstants.cardRadius * frame,
          );

          return Center(
            child: AspectRatio(
              aspectRatio: lerpDouble(
                StackConstants.defaultCardAspectRatio,
                pageAspectRatio,
                t,
              )!,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(
                        alpha: StackConstants.cardShadowOpacity * frame,
                      ),
                      blurRadius: StackConstants.cardShadowBlur,
                      offset: StackConstants.cardShadowOffset,
                    ),
                  ],
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: colorScheme.surface.withValues(alpha: frame),
                    width: StackConstants.cardBorderWidth,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: image,
              ),
            ),
          );
        },
      ),
      ),
    );
  };
}

/// The page at full resolution, fading in over its thumbnail once ready.
class _FullPageImage extends StatelessWidget {
  const _FullPageImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        // Already decoded (seen before): nothing to fade from.
        if (wasSynchronouslyLoaded) {
          return child;
        }

        // The thumbnail is usually cached from the grid, so it shows at
        // once; the full image fades in over it on its first frame.
        return Stack(
          fit: StackFit.expand,
          children: [
            ThumbnailImage(path: path, fit: BoxFit.contain),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: AppDurations.fast,
              child: child,
            ),
          ],
        );
      },
    );
  }
}