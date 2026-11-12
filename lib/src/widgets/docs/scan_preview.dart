import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs/scan_preview_controller.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/scan_view_models.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:my_reviewer/src/widgets/common/dialogs/progress_dialog.dart';
import 'package:my_reviewer/src/widgets/docs/scan_preview/docs_scan_preview_bottom_bar.dart';
import 'package:my_reviewer/src/widgets/docs/scan_preview/docs_scan_preview_nav_overlay.dart';
import 'package:my_reviewer/src/widgets/docs/scan_preview/docs_scan_preview_page_viewer.dart';
import 'package:my_reviewer/src/widgets/docs/scan_preview/scan_more_button.dart';

class DocsScanPreview<R> extends StatelessWidget {
  const DocsScanPreview({
    super.key,
    required this._controller,
    required this._saveTask,
     this._onSaved,
    required this._saveAvailability,
    required this._emptyMessage,
  });

  final ScanPreviewController _controller;
  final ProgressTask<R> _saveTask;

  final ValueChanged<R>? _onSaved;

  final SaveAvailability _saveAvailability;
  /// Differs per flow: "scan to start" vs "saving will delete the group".
  final String _emptyMessage;

  Future<void> _save(BuildContext context) async {
    final status = await ProgressDialog.run(
      context,
      task: _saveTask,
      kind: OperationKind.save,
    );

    if (!context.mounted || status != OperationStatus.succeeded) {
      return;
    }

    // Set on every successful run; nullable only before the first one.
    _onSaved?.call(_saveTask.result as R);
  }

  @override
  Widget build(BuildContext context) {
    final strings = t.docs.scan.preview;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final pageCount = _controller.pageCount;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              pageCount == 0
                  ? strings.emptyTitle
                  : strings.title(
                      current: (_controller.currentIndex + 1).toString(),
                      total: pageCount.toString(),
                    ),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: switch (_saveAvailability) {
                  SaveAvailability.available => () => _save(context),
                  SaveAvailability.nothingToSave => null,
                },
                icon: const Icon(Icons.save_outlined),
                label: Text(strings.save),
              ),
            ],
          ),
          body: SafeArea(
            child: pageCount == 0
                ? _EmptyBody(message: _emptyMessage, controller: _controller)
                : _PagesBody(controller: _controller),
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
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
    _pageController.dispose();
    super.dispose();
  }

  /// Moves the page view when the controller changed the index itself,
  /// e.g. clamping it after a removal.
  void _followCurrentIndex() {
    if (!_pageController.hasClients || widget.controller.pageCount == 0) {
      return;
    }

    final target = widget.controller.currentIndex;

    if (_pageController.page?.round() != target) {
      _pageController.jumpToPage(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              DocsScanPreviewPageViewer(
                pageController: _pageController,
                controller: widget.controller,
              ),
              DocsScanPreviewNavOverlay(
                pageController: _pageController,
                controller: widget.controller,
              ),
            ],
          ),
        ),
        DocsScanPreviewBottomBar(
          onPageSelected: _pageController.jumpToPage,
          controller: widget.controller,
        ),
      ],
    );
  }
}
