import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs_scan_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/utils/string.dart';
import 'package:my_reviewer/src/widgets/docs_scan_screen/docs_scan_group_bottom_sheet.dart';
import 'package:my_reviewer/src/widgets/name_text_field.dart';
import 'package:provider/provider.dart';

/// Name field and actions for the page currently shown in the preview.
class DocsScanBottomBar extends StatelessWidget {
  const DocsScanBottomBar({super.key, required this.onPageSelected});

  /// Called when the user picks a page in the group sheet.
  final ValueChanged<int> onPageSelected;

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = t.docs.scan.preview;

    final currentIndex = context.select(
      (DocsScanController controller) => controller.currentIndex,
    );
    final currentDoc = context.select(
      (DocsScanController controller) => controller.currentDoc,
    );
    final nameValidation = context.select(
      (DocsScanController controller) => controller.currentDocNameValidation,
    );
    final pageCount = context.select(
      (DocsScanController controller) => controller.pageCount,
    );

    if (currentDoc == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NameTextField(
              // A new key per document gives each page its own field state,
              // so the text never has to be synced by hand on page change.
              key: ValueKey(currentDoc.id),
              initialValue: currentDoc.name,
              labelText: strings.docNameLabel,
              hintText: strings.docNamePlaceholder,
              errorText: switch (nameValidation) {
                NameValidation.valid => null,
                NameValidation.empty => strings.docNameError,
              },
              onChanged: (value) {
                context.read<DocsScanController>().updateDocName(
                  currentIndex,
                  value,
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: strings.bottomBar.addTooltip,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  color: colorScheme.primary,
                  onPressed: () {
                    _dismissKeyboard();
                    context.read<DocsScanController>().scanMorePages();
                  },
                ),
                TextButton.icon(
                  onPressed: () {
                    _dismissKeyboard();
                    DocsScanGroupBottomSheet.show(
                      context,
                      onPageSelected: onPageSelected,
                    );
                  },
                  icon: const Icon(Icons.grid_view_outlined),
                  label: Text(
                    strings.bottomBar.groupButton(count: pageCount),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  tooltip: strings.bottomBar.deleteTooltip,
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () {
                    _dismissKeyboard();
                    context.read<DocsScanController>().removeDocAt(
                      currentIndex,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
