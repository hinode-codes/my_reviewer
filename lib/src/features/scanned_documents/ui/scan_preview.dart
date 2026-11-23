import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_preview_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanner.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan/scan_more_button.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan/scan_preview_bottom_bar.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan/scan_preview_nav_overlay.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan/scan_preview_page_viewer.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/task_dialog.dart';

class ScanPreview<R> extends StatelessWidget {
  const ScanPreview({
    super.key,
    required this.controller,
    required this.saveTask,
    this.onSaved,
    required this.saveAvailability,
    required this.emptyMessage,
  });

  final ScanPreviewController controller;
  final TaskController<R> saveTask;
  final ValueChanged<R>? onSaved;
  final SaveAvailability saveAvailability;
  final String emptyMessage;

  Future<void> _save(BuildContext context) async {
    final count = controller.pages.length;
    final saveStrings = t.docs.scan.save.status;

    final status = await TaskDialog.run(
      context,
      task: saveTask,
      kind: TaskKind.save,
      messages: TaskDialogMessages(
        preparing: saveStrings.preparing(n: count),
        processing: (current, total) =>
            saveStrings.saving(current: current, total: total),
        succeeded: saveStrings.done(n: count),
        failed: saveStrings.failed(n: count),
      ),
    );

    if (!context.mounted || status != TaskStatus.succeeded) {
      return;
    }

    onSaved?.call(saveTask.result as R);
  }

  @override
  Widget build(BuildContext context) {
    final strings = t.docs.scan.preview;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final pageCount = controller.pageCount;
        final title = pageCount == 0
            ? strings.empty.title
            : strings.title(
                current: controller.currentIndex + 1,
                total: pageCount,
              );

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(title),
            actions: [
              ElevatedButton.icon(
                onPressed: switch (saveAvailability) {
                  SaveAvailability.available => () => _save(context),
                  SaveAvailability.nothingToSave => null,
                },
                icon: const Icon(Icons.save_outlined),
                label: Text(strings.actions.save),
              ),
            ],
          ),
          body: pageCount == 0
              ? _EmptyBody(message: emptyMessage, controller: controller)
              : _PagesBody(controller: controller),
        );
      },
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.message, required this.controller});

  final String message;
  final ScanPreviewController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          ScanMoreButton(
            variant: ScanMoreButtonVariant.filled,
            onPressed: () => unawaited(controller.scan()),
          ),
        ],
      ),
    );
  }
}

/// Exists only while there are pages, so its page controller is created
/// fresh, at the current index, each time pages come back.
class _PagesBody extends StatefulWidget {
  const _PagesBody({required this.controller});

  final ScanPreviewController controller;

  @override
  State<_PagesBody> createState() => _PagesBodyState();
}

class _PagesBodyState extends State<_PagesBody> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: widget.controller.currentIndex,
    );

    widget.controller.addListener(_followCurrentIndex);
  }

  @override
  void didUpdateWidget(_PagesBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_followCurrentIndex);
      widget.controller.addListener(_followCurrentIndex);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_followCurrentIndex);
    pageController.dispose();
    super.dispose();
  }

  /// Moves the page view when the controller changed the index itself,
  /// e.g. clamping it after a removal.
  void _followCurrentIndex() {
    if (!pageController.hasClients || widget.controller.pageCount == 0) {
      return;
    }

    final target = widget.controller.currentIndex;

    if (pageController.page?.round() != target) {
      pageController.jumpToPage(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ScanPreviewPageViewer(
                pageController: pageController,
                imagePaths: widget.controller.imagePaths,
                onPageChanged: (index) {
                  widget.controller.setCurrentIndex(index);
                },
              ),
              ScanPreviewNavOverlay(
                pageController: pageController,
                index: widget.controller.currentIndex,
                pageCount: widget.controller.pageCount,
              ),
            ],
          ),
        ),

        ScanPreviewBottomBar(
          onPageSelected: pageController.jumpToPage,
          controller: widget.controller,
        ),
      ],
    );
  }
}
