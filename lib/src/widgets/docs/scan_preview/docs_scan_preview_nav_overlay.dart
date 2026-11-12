import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_scan_constants.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs/scan_preview_controller.dart';
import 'package:my_reviewer/src/widgets/circle_nav_icon_button.dart';

/// Previous / next buttons laid over the page viewer.
class DocsScanPreviewNavOverlay extends StatelessWidget {
  const DocsScanPreviewNavOverlay({
    super.key,
    required this.pageController,
    required this.controller,
  });

  final PageController pageController;
  final ScanPreviewController controller;

  void _goToPrevious() {
    pageController.previousPage(
      duration: AppDurations.medium,
      curve: DocsScanConstants.pageTransitionCurve,
    );
  }

  void _goToNext() {
    pageController.nextPage(
      duration: AppDurations.medium,
      curve: DocsScanConstants.pageTransitionCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = controller.currentIndex;
    final pageCount = controller.pageCount;

    return Stack(
      children: [
        _EdgeSlot(
          alignment: Alignment.centerLeft,
          child: CircleNavIconButton(
            icon: Icons.chevron_left_outlined,
            onPressed: currentIndex > 0 ? _goToPrevious : null,
          ),
        ),
        _EdgeSlot(
          alignment: Alignment.centerRight,
          child: CircleNavIconButton(
            icon: Icons.chevron_right_outlined,
            onPressed: currentIndex < pageCount - 1 ? _goToNext : null,
          ),
        ),
      ],
    );
  }
}

class _EdgeSlot extends StatelessWidget {
  const _EdgeSlot({required this.alignment, required this.child});

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: child,
      ),
    );
  }
}
