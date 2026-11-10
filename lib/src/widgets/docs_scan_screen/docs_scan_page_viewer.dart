import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_scan_constants.dart';
import 'package:my_reviewer/src/controllers/docs_scan_controller.dart';
import 'package:provider/provider.dart';

/// Swipeable, zoomable pages of the current scan session.
class DocsScanPageViewer extends StatelessWidget {
  const DocsScanPageViewer({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final imagePaths = context.watch<DocsScanController>().tempImagePaths;

    return PageView.builder(
      controller: pageController,
      itemCount: imagePaths.length,
      onPageChanged: (index) {
        context.read<DocsScanController>().setCurrentIndex(index);
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
