import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/constants/scan_constants.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/ui/circle_icon_button.dart';

class ScanPreviewNavOverlay extends StatelessWidget {
  const ScanPreviewNavOverlay({
    super.key,
    required this.pageController,
    required this.index,
    required this.pageCount,
  });

  final PageController pageController;
  final int index;
  final int pageCount;

  void _goToPrevious() {
    pageController.previousPage(
      duration: AnimationConstants.md,
      curve: DocsScanConstants.pageTransitionCurve,
    );
  }

  void _goToNext() {
    pageController.nextPage(
      duration: AnimationConstants.md,
      curve: DocsScanConstants.pageTransitionCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _EdgeSlot(
          alignment: Alignment.centerLeft,
          child: CircleIconButton(
            icon: Icons.chevron_left_outlined,
            onPressed: index > 0 ? _goToPrevious : null,
          ),
        ),
        _EdgeSlot(
          alignment: Alignment.centerRight,
          child: CircleIconButton(
            icon: Icons.chevron_right_outlined,
            onPressed: index < pageCount - 1 ? _goToNext : null,
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
