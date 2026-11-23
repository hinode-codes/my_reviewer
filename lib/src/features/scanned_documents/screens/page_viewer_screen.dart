import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_viewer_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';
import 'package:provider/provider.dart';

class PageViewerScreen extends StatelessWidget {
  const PageViewerScreen({super.key, required this.navigator});

  final Widget navigator;

  @override
  Widget build(BuildContext context) {
    final status = context.select<PageViewerController, ItemsStatus>(
      (c) => c.status,
    );

    return switch (status) {
      ItemsStatus.ready => navigator,
      ItemsStatus.failed => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(t.common.status.failed)),
      ),
      ItemsStatus.loading => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator.adaptive(
            semanticsLabel: t.common.status.loading,
          ),
        ),
      ),
    };
  }
}
