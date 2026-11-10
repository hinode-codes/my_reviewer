import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';

/// Shown when a scan attempt finished and there are still no pages.
class DocsScanEmptyView extends StatelessWidget {
  const DocsScanEmptyView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.docs.scan.title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.docs.scan.noDocsCaptured,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(t.docs.scan.noDocsRetry),
            ),
          ],
        ),
      ),
    );
  }
}
