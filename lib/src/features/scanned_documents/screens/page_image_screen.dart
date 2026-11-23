import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/constants/ui_constants.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_viewer_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/viewer/page_flight_shuttle.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/hero_tags.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/zoom.dart';
import 'package:my_reviewer/src/shared/ui/zoom/zoomable_page.dart';
import 'package:my_reviewer/src/shared/ui/zoom/zoomable_page_view.dart';
import 'package:provider/provider.dart';

/// Full-screen scanned page image viewer.
///
/// Shares [PageViewerController] with the transcription route via the
/// parent shell route so swiping pages in either view keeps `currentIndex`
/// synchronized, and popping from either flies the active page back to its
/// matching grid tile.
class DocsPageImageScreen extends StatefulWidget {
  const DocsPageImageScreen({super.key});

  @override
  State<DocsPageImageScreen> createState() => _DocsPageImageScreenState();
}

class _DocsPageImageScreenState extends State<DocsPageImageScreen> {
  late final PageController _pageController;
  late final PageViewerController _viewerController;

  @override
  void initState() {
    super.initState();
    _viewerController = context.read<PageViewerController>();
    _pageController = PageController(
      initialPage: _viewerController.currentIndex,
    );
    _viewerController.addListener(_syncPageController);
  }

  @override
  void dispose() {
    _viewerController.removeListener(_syncPageController);
    _pageController.dispose();
    super.dispose();
  }

  void _syncPageController() {
    if (!_pageController.hasClients) {
      return;
    }

    final targetIndex = _viewerController.currentIndex;
    final settledPage = _pageController.page?.round();

    if (settledPage != null && settledPage != targetIndex) {
      _pageController.jumpToPage(targetIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final docs = context
        .select<PageViewerController, List<ScannedDocumentModel>>(
          (c) => c.docs,
        );
    final absolutePaths = context.select<PageViewerController, List<String>>(
      (c) => c.absolutePaths,
    );
    final currentIndex = context.select<PageViewerController, int>(
      (c) => c.currentIndex,
    );
    final zoom = context.select<PageViewerController, PageZoom>((c) => c.zoom);

    final currentDoc = docs[currentIndex];

    return Scaffold(
      backgroundColor: colorScheme.scrim,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colorScheme.scrim.withValues(alpha: 0.35),
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentDoc.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '${currentIndex + 1} / ${docs.length}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: t.docs.transcription.actions.view,
            icon: const Icon(Icons.text_fields_outlined),
            onPressed: () {
              DocsPageViewerTranscriptionRouteData(
                groupId: currentDoc.groupId,
                docId: currentDoc.id,
              ).go(context);
            },
          ),
        ],
      ),
      body: ZoomablePageView(
        controller: _pageController,
        itemCount: docs.length,
        currentIndex: currentIndex,
        zoom: zoom,
        onPageChanged: _viewerController.showPage,
        pageAnnouncementBuilder: (index, total) =>
            '${docs[index].name}, ${index + 1} / $total',
        itemBuilder: (context, index, zoomKey) {
          final doc = docs[index];
          final absolutePath = absolutePaths[index];
          final isCurrent = index == currentIndex;

          return HeroMode(
            enabled: isCurrent,
            child: Hero(
              tag: pageHeroTag(doc.groupId, doc.relativePath),
              transitionOnUserGestures: true,
              flightShuttleBuilder: buildPageFlightShuttle(absolutePath),
              child: ZoomablePage(
                key: zoomKey,
                isActive: isCurrent,
                isZoomed: zoom == PageZoom.zoomed,
                onZoomChanged: _viewerController.setZoom,
                maxScale: DocsUiConstants.viewerMaxScale,
                doubleTapScale: DocsUiConstants.viewerDoubleTapScale,
                semanticLabel: '${doc.name}, ${index + 1} / ${docs.length}',
                child: SizedBox.expand(
                  child: FullPageImage(absolutePath: absolutePath),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
