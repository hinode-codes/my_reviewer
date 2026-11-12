
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_scan_constants.dart';
import 'package:my_reviewer/src/controllers/docs/scan_preview_controller.dart';

class DocsScanPreviewPageViewer extends StatelessWidget {
  const DocsScanPreviewPageViewer({super.key, required this.pageController, required this.controller});

  final PageController pageController;
  final ScanPreviewController controller;

  @override
  Widget build(BuildContext context) {
    final imagePaths = controller.imagePaths;

    return PageView.builder(
      controller: pageController,
      itemCount: imagePaths.length,
      onPageChanged: (index) {
        controller.setCurrentIndex(index);
      },
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
