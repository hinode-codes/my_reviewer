import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_transcription.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_viewer_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/page_transcription_state.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/viewer/page_flight_shuttle.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/hero_tags.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:provider/provider.dart';

/// Child route of [PageViewerScreens] for viewing and streaming OCR
/// transcriptions per scanned page.
///
/// Shares [PageViewerController] with [PageImageScreen] so horizontal
/// swipes keep `currentIndex` synchronized across both modes, and popping from
/// either screen flies the active page back to its matching grid tile.
class PageTranscriptionScreen extends StatefulWidget {
  const PageTranscriptionScreen({super.key});

  @override
  State<PageTranscriptionScreen> createState() =>
      _PageTranscriptionScreenState();
}

class _PageTranscriptionScreenState extends State<PageTranscriptionScreen> {
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

  void _handlePageChanged(int index, List<ScannedDocumentModel> docs) {
    _viewerController.showPage(index);

    if (!mounted) {
      return;
    }

    final view = View.of(context);
    final direction = Directionality.of(context);

    SemanticsService.sendAnnouncement(
      view,
      '${docs[index].name}, ${index + 1} / ${docs.length}',
      direction,
    );
  }

  Future<void> _copyMarkdown(String markdown) async {
    await Clipboard.setData(ClipboardData(text: markdown));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.common.actions.copied),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
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

    final currentDoc = docs[currentIndex];
    final currentState = context
        .select<PageTranscriptionController, PageTranscriptionState>(
          (c) => c.stateFor(currentDoc),
        );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentDoc.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '${currentIndex + 1} / ${docs.length}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          if (currentState case TranscriptionReady(:final markdown))
            IconButton(
              tooltip: t.common.actions.copy,
              icon: const Icon(Icons.copy_outlined),
              onPressed: () => _copyMarkdown(markdown),
            ),
          IconButton(
            tooltip: t.docs.transcription.actions.viewImage,
            icon: const Icon(Icons.image_outlined),
            onPressed: () {
              DocsPageViewerRouteData(
                groupId: currentDoc.groupId,
                docId: currentDoc.id,
              ).go(context);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: docs.length,
        onPageChanged: (index) => _handlePageChanged(index, docs),
        itemBuilder: (context, index) {
          final doc = docs[index];
          final absolutePath = absolutePaths[index];
          final isCurrent = index == currentIndex;

          return ExcludeSemantics(
            excluding: !isCurrent,
            child: HeroMode(
              enabled: isCurrent,
              child: Hero(
                tag: pageHeroTag(doc.groupId, doc.relativePath),
                transitionOnUserGestures: true,
                flightShuttleBuilder: buildPageFlightShuttle(absolutePath),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: _TranscriptionPageBody(doc: doc),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TranscriptionPageBody extends StatelessWidget {
  const _TranscriptionPageBody({required this.doc});

  final ScannedDocumentModel doc;

  @override
  Widget build(BuildContext context) {
    final state = context
        .select<PageTranscriptionController, PageTranscriptionState>(
          (c) => c.stateFor(doc),
        );

    return switch (state) {
      TranscriptionNotQueued() => _NotQueuedView(doc: doc),
      TranscriptionQueued(:final queuePosition, :final partialMarkdown) =>
        _QueuedView(
          queuePosition: queuePosition,
          partialMarkdown: partialMarkdown,
        ),
      TranscriptionInProgress(
        :final streamingMarkdown,
        :final wordCount,
        :final elapsedMs,
      ) =>
        _StreamingView(
          streamingMarkdown: streamingMarkdown,
          wordCount: wordCount,
          elapsedMs: elapsedMs,
        ),
      TranscriptionReady(
        :final markdown,
        :final wordCount,
        :final timeMsToRead,
        :final timeMsToTranscribe,
      ) =>
        _ReadyView(
          markdown: markdown,
          wordCount: wordCount,
          timeMsToRead: timeMsToRead,
          timeMsToTranscribe: timeMsToTranscribe,
        ),
      TranscriptionFailed(:final partialMarkdown, :final errorMessage) =>
        _FailedView(
          doc: doc,
          partialMarkdown: partialMarkdown,
          errorMessage: errorMessage,
        ),
    };
  }
}

class _NotQueuedView extends StatelessWidget {
  const _NotQueuedView({required this.doc});

  final ScannedDocumentModel doc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.document_scanner_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                t.docs.transcription.empty.title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t.docs.transcription.empty.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () =>
                    context.read<PageTranscriptionController>().enqueue(doc),
                icon: const Icon(Icons.playlist_add_outlined),
                label: Text(t.docs.transcription.actions.start),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueuedView extends StatelessWidget {
  const _QueuedView({
    required this.queuePosition,
    required this.partialMarkdown,
  });

  final int? queuePosition;
  final String? partialMarkdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  queuePosition != null
                      ? t.docs.transcription.status.queuedAtPosition(
                          position: queuePosition!,
                        )
                      : t.docs.transcription.status.queued,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t.docs.transcription.status.queuedDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => debugPrint("Go to queue"),
                  icon: const Icon(Icons.queue_outlined),
                  label: Text(t.docs.transcription.actions.goToQueue),
                ),
              ],
            ),
          ),
        ),
        if (partialMarkdown != null) ...[
          const SizedBox(height: 20),
          Text(
            t.docs.transcription.status.partialPreview,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _MarkdownContent(markdown: partialMarkdown!),
        ],
      ],
    );
  }
}

class _StreamingView extends StatefulWidget {
  const _StreamingView({
    required this.streamingMarkdown,
    required this.wordCount,
    required this.elapsedMs,
  });

  final String streamingMarkdown;
  final int wordCount;
  final int elapsedMs;

  @override
  State<_StreamingView> createState() => _StreamingViewState();
}

class _StreamingViewState extends State<_StreamingView> {
  final ScrollController _scrollController = ScrollController();
  bool _userScrolledAway = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _StreamingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streamingMarkdown != oldWidget.streamingMarkdown &&
        !_userScrolledAway) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) {
          return;
        }
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent > 0) {
          _scrollController.jumpTo(maxExtent);
        }
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final distanceFromBottom = position.maxScrollExtent - position.pixels;
    _userScrolledAway = distanceFromBottom > 48;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final elapsedSeconds = (widget.elapsedMs / 1000).toStringAsFixed(1);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.45),
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.docs.transcription.status.streaming,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${t.docs.transcription.stats.wordCount(n: widget.wordCount)} · ${elapsedSeconds}s',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.streamingMarkdown.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator.adaptive(
                        semanticsLabel: t.docs.transcription.status.streaming,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.docs.transcription.status.warmingUp,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _MarkdownContent(markdown: widget.streamingMarkdown),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: _StreamingCursor(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _StreamingCursor extends StatefulWidget {
  const _StreamingCursor();

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final cursorColor = Theme.of(context).colorScheme.primary;

    final bar = Container(
      width: 8,
      height: 18,
      decoration: BoxDecoration(
        color: cursorColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );

    if (reduceMotion) {
      return bar;
    }

    return FadeTransition(opacity: _controller, child: bar);
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.markdown,
    required this.wordCount,
    required this.timeMsToRead,
    required this.timeMsToTranscribe,
  });

  final String markdown;
  final int wordCount;
  final int timeMsToRead;
  final int timeMsToTranscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final readSeconds = (timeMsToRead / 1000).round();
    final transcribeSeconds = (timeMsToTranscribe / 1000).round();

    return SelectableRegion(
      selectionControls: materialTextSelectionControls,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetadataChip(
                icon: Icons.notes_outlined,
                label: t.docs.transcription.stats.wordCount(n: wordCount),
              ),
              _MetadataChip(
                icon: Icons.schedule_outlined,
                label: t.docs.transcription.stats.readTime(
                  seconds: readSeconds,
                ),
              ),
              _MetadataChip(
                icon: Icons.bolt_outlined,
                label: t.docs.transcription.stats.transcribeTime(
                  seconds: transcribeSeconds,
                ),
              ),
            ],
          ),
          Divider(height: 24, color: colorScheme.outlineVariant),
          _MarkdownContent(markdown: markdown),
        ],
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView({
    required this.doc,
    required this.partialMarkdown,
    required this.errorMessage,
  });

  final ScannedDocumentModel doc;
  final String? partialMarkdown;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card.outlined(
          color: colorScheme.errorContainer.withValues(alpha: 0.25),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  t.docs.transcription.errors.failedTitle,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      context.read<PageTranscriptionController>().requeue(doc),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(t.docs.transcription.actions.retry),
                ),
              ],
            ),
          ),
        ),
        if (partialMarkdown != null) ...[
          const SizedBox(height: 20),
          Text(
            t.docs.transcription.status.partialPreview,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _MarkdownContent(markdown: partialMarkdown!),
        ],
      ],
    );
  }
}

class _MarkdownContent extends StatelessWidget {
  const _MarkdownContent({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return MarkdownBody(
      data: markdown,
      selectable: false,
      styleSheet: MarkdownStyleSheet(
        p: textTheme.bodyLarge?.copyWith(height: 1.6),
        h1: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        h2: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        h3: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        h4: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        h5: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        h6: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        em: const TextStyle(fontStyle: FontStyle.italic),
        strong: const TextStyle(fontWeight: FontWeight.bold),
        del: const TextStyle(decoration: TextDecoration.lineThrough),
        code: textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquote: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: colorScheme.primary, width: 3),
          ),
        ),
        listBullet: textTheme.bodyLarge,
        tableHead: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        tableBody: textTheme.bodyMedium,
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
      ),
    );
  }
}
