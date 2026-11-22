import 'dart:async';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs/transcription_viewer_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:provider/provider.dart';

class DocsPageTranscriptionScreen extends StatelessWidget {
  const DocsPageTranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageStatus = context
        .select<TranscriptionViewerController, ItemsStatus>(
          (c) => c.pageStatus,
        );

    return switch (pageStatus) {
      ItemsStatus.loading => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator.adaptive(
            semanticsLabel: t.common.status.loading,
          ),
        ),
      ),
      ItemsStatus.failed => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(t.common.status.failed)),
      ),
      ItemsStatus.ready => const _TranscriptionBody(),
    };
  }
}

class _TranscriptionBody extends StatelessWidget {
  const _TranscriptionBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TranscriptionViewerController>();
    final doc = context
        .select<TranscriptionViewerController, ScannedDocumentModel>(
          (c) => c.currentDoc,
        );
    final docs = context
        .select<TranscriptionViewerController, List<ScannedDocumentModel>>(
          (c) => c.docs,
        );
    final viewStatus = context
        .select<TranscriptionViewerController, TranscriptionViewStatus>(
          (c) => c.viewStatus,
        );
    final markdown = context.select<TranscriptionViewerController, String>(
      (c) => c.markdown,
    );
    final saved = context
        .select<
          TranscriptionViewerController,
          ScannedDocumentTranscriptionModel?
        >((c) => c.savedTranscription);
    final errorMessage = context.select<TranscriptionViewerController, String?>(
      (c) => c.errorMessage,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.name),
        actions: [
          if (viewStatus == TranscriptionViewStatus.ready)
            IconButton(
              tooltip: t.docs.transcription.retranscribe,
              icon: const Icon(Icons.refresh),
              onPressed: () => unawaited(controller.startTranscription()),
            ),
          IconButton(
            tooltip: t.docs.transcription.viewImage,
            icon: const Icon(Icons.image_outlined),
            onPressed: () {
              DocsPageViewerRouteData(
                docId: doc.id,
                groupId: doc.groupId,
                $extra: docs,
              ).go(context);
            },
          ),
        ],
      ),
      body: switch (viewStatus) {
        TranscriptionViewStatus.idle => _IdleTranscriptionView(
          onTranscribe: () => unawaited(controller.startTranscription()),
        ),
        TranscriptionViewStatus.queued => _QueuedTranscriptionView(
          onCancel: () => unawaited(controller.cancelTranscription()),
        ),
        TranscriptionViewStatus.streaming => _StreamingTranscriptionView(
          markdown: markdown,
          onCancel: () => unawaited(controller.cancelTranscription()),
        ),
        TranscriptionViewStatus.ready => _ReadyTranscriptionView(
          markdown: markdown,
          transcription: saved!,
        ),
        TranscriptionViewStatus.failed => _FailedTranscriptionView(
          error: errorMessage,
          onRetry: () => unawaited(controller.retryTranscription()),
        ),
      },
    );
  }
}

class _IdleTranscriptionView extends StatelessWidget {
  const _IdleTranscriptionView({required this.onTranscribe});

  final VoidCallback onTranscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              t.docs.transcription.emptyTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.docs.transcription.emptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onTranscribe,
              icon: const Icon(Icons.auto_awesome),
              label: Text(t.docs.transcription.startAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueuedTranscriptionView extends StatelessWidget {
  const _QueuedTranscriptionView({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: AppSpacing.md),
            Text(t.docs.transcription.queuedStatus),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(t.common.buttons.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamingTranscriptionView extends StatelessWidget {
  const _StreamingTranscriptionView({
    required this.markdown,
    required this.onCancel,
  });

  final String markdown;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.docs.transcription.streamingStatus,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(t.common.buttons.cancel),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: markdown.isEmpty
              ? const Center(child: CircularProgressIndicator.adaptive())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: MarkdownBody(data: markdown, selectable: true),
                ),
        ),
      ],
    );
  }
}

class _ReadyTranscriptionView extends StatelessWidget {
  const _ReadyTranscriptionView({
    required this.markdown,
    required this.transcription,
  });

  final String markdown;
  final ScannedDocumentTranscriptionModel transcription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readSeconds = (transcription.timeMsToRead / 1000).ceil();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          color: theme.colorScheme.surfaceContainerLow,
          child: Text(
            t.docs.transcription.stats(
              words: transcription.wordCount,
              seconds: readSeconds,
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: MarkdownBody(data: markdown, selectable: true),
          ),
        ),
      ],
    );
  }
}

class _FailedTranscriptionView extends StatelessWidget {
  const _FailedTranscriptionView({required this.error, required this.onRetry});

  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(t.common.status.failed, style: theme.textTheme.titleMedium),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(t.common.buttons.retry),
            ),
          ],
        ),
      ),
    );
  }
}
