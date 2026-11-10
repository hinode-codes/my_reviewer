import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_scan_constants.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs_scan_controller.dart';
import 'package:my_reviewer/src/widgets/circle_nav_icon_button.dart';
import 'package:provider/provider.dart';

/// Previous / next buttons laid over the page viewer.
class DocsScanNavOverlay extends StatelessWidget {
  const DocsScanNavOverlay({super.key, required this.pageController});

  final PageController pageController;

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
    final currentIndex = context.select(
      (DocsScanController controller) => controller.currentIndex,
    );
    final pageCount = context.select(
      (DocsScanController controller) => controller.pageCount,
    );

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
