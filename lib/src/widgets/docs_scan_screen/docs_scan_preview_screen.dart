import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs_scan_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs_scan_state.dart';
import 'package:my_reviewer/src/widgets/save_progress_dialog.dart';
import 'package:my_reviewer/src/widgets/docs_scan_screen/docs_scan_bottom_bar.dart';
import 'package:my_reviewer/src/widgets/docs_scan_screen/docs_scan_nav_overlay.dart';
import 'package:my_reviewer/src/widgets/docs_scan_screen/docs_scan_page_viewer.dart';
import 'package:provider/provider.dart';

class DocsScanPreviewScreen extends StatefulWidget {
  const DocsScanPreviewScreen({super.key});

  @override
  State<DocsScanPreviewScreen> createState() => _DocsScanPreviewScreenState();
}

class _DocsScanPreviewScreenState extends State<DocsScanPreviewScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: context.read<DocsScanController>().currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Runs the save behind the progress dialog, then leaves on success. On
  /// failure the dialog offers a retry and the user stays with scans intact.
  Future<void> _save() async {
    final controller = context.read<DocsScanController>();
    final status = await SaveProgressDialog.run(
      context,
      controller: controller,
    );

    if (!mounted) {
      return;
    }

    if (status == SaveStatus.saved) {
      final navigator = Navigator.of(context);

      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.select(
      (DocsScanController controller) => controller.currentIndex,
    );
    final pageCount = context.select(
      (DocsScanController controller) => controller.pageCount,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          t.docs.scan.preview.title(
            current: (currentIndex + 1).toString(),
            total: pageCount.toString(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(t.docs.scan.preview.save),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  DocsScanPageViewer(pageController: _pageController),
                  DocsScanNavOverlay(pageController: _pageController),
                ],
              ),
            ),
            DocsScanBottomBar(onPageSelected: _pageController.jumpToPage),
          ],
        ),
      ),
    );
  }
}
