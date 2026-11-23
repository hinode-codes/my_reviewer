import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/constants/scan_constants.dart';

class ScanPreviewPageViewer extends StatelessWidget {
  const ScanPreviewPageViewer({
    super.key,
    required this.pageController,
    required this.imagePaths,
    required this.onPageChanged,
  });

  final PageController pageController;
  final List<String> imagePaths;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: imagePaths.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: DocsScanConstants.previewMinScale,
          maxScale: DocsScanConstants.previewMaxScale,
          child: Center(
            child: Image.file(File(imagePaths[index]), fit: BoxFit.contain),
          ),
        );
      },
    );
  }
}
