import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/stack_constants.dart';
import 'package:my_reviewer/src/controllers/docs/page_viewer_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/utils/hero_tags.dart';
import 'package:my_reviewer/src/widgets/common/misc/thumbnail/thumbnail_card.dart';
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

/// Stateful only to own the PageController, which is a widget-side object
/// that must be disposed. Which page shows lives in the controller.
class _PageViewerState extends State<_PageViewer> {
  late final PageController _pageController;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final docs = context.select<DocsPageViewerController, List<ScannedDocumentModel>>(
      (c) => c.docs,
    );
    final currentIndex = context.select<DocsPageViewerController, int>(
      (c) => c.currentIndex,
    );

    return Scaffold(
      backgroundColor: colorScheme.scrim,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colorScheme.scrim.withValues(alpha: 0),
        foregroundColor: colorScheme.onPrimary,
        title: Text(docs[currentIndex].name),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: docs.length,
        onPageChanged: (index) =>
            context.read<DocsPageViewerController>().showPage(index),
        itemBuilder: (context, index) => _ViewerPage(
          doc: docs[index],
          isCurrent: index == currentIndex,
        ),
      ),
    );
  }
}

class _ViewerPage extends StatelessWidget {
  const _ViewerPage({required this.doc, required this.isCurrent});

  final ScannedDocumentModel doc;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Center(
      // Same page shape as the grid tile, so the flight has a real box to
      // land on from the first frame, before the full image has decoded.
      child: AspectRatio(
        aspectRatio: StackConstants.defaultCardAspectRatio,
        // PageView keeps neighbouring pages built offscreen; only the page
        // showing may fly, or neighbours would fly in from off screen.
        // HeroMode switches that without changing the tree, so a page keeps
        // its state when it becomes the current one.
        child: HeroMode(
          enabled: isCurrent,
          child: Hero(
            tag: pageHeroTag(doc.groupId, doc.absoluteFilePath),
            transitionOnUserGestures: true,
            flightShuttleBuilder: _pageShuttle(doc.absoluteFilePath),
            child: InteractiveViewer(
              child: _FullPageImage(path: doc.absoluteFilePath),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flies a page between the grid's framed card and the viewer's bare image,
/// fading the frame out on the way in and back in on the way out.
///
/// Used both ways: on push the viewer is the destination, whose shuttle
/// wins; on pop the grid tile has none, so the viewer's is used again.
HeroFlightShuttleBuilder _pageShuttle(String path) {
  return (flightContext, animation, direction, fromHeroContext, toHeroContext) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ThumbnailImage(path: path, fit: BoxFit.contain),
        // The route animation is 0 at the grid and 1 at the viewer in both
        // directions, so the frame is fully shown at the grid end only.
        FadeTransition(
          opacity: ReverseAnimation(animation),
          child: ThumbnailCard(path: path),
        ),
      ],
    );
  };
}

/// The page at full resolution, showing the thumbnail until it is ready.
class _FullPageImage extends StatelessWidget {
  const _FullPageImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      gaplessPlayback: true,
      // The thumbnail is already in the image cache from the grid, so it
      // shows at once; the full image replaces it on its first frame.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          frame == null && !wasSynchronouslyLoaded
          ? ThumbnailImage(path: path, fit: BoxFit.contain)
          : child,
    );
  }
}