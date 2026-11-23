import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_preview_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan/scan_preview_bottom_sheet.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/ui/text_field/name_text_field.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';

class ScanPreviewBottomBar extends StatelessWidget {
  const ScanPreviewBottomBar({
    super.key,
    required this.onPageSelected,
    required this.controller,
  });

  final ValueChanged<int> onPageSelected;
  final ScanPreviewController controller;

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = t.docs.scan.preview;

    final currentIndex = controller.currentIndex;
    final currentDoc = controller.currentPage;
    final nameValidation = controller.currentDocNameValidation;
    final pageCount = controller.pageCount;

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
              labelText: strings.fields.docName.label,
              hintText: strings.fields.docName.placeholder,
              errorText: switch (nameValidation) {
                NameValidation.valid => null,
                NameValidation.empty => strings.fields.docName.errors.empty,
              },
              onChanged: (value) {
                controller.updateDocName(currentIndex, value);
              },
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: strings.tooltips.add,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  color: colorScheme.primary,
                  onPressed: () {
                    _dismissKeyboard();
                    unawaited(controller.scan());
                  },
                ),
                TextButton.icon(
                  onPressed: () {
                    _dismissKeyboard();
                    ScanPreviewBottomSheet.show(
                      context,
                      controller: controller,
                      onPageSelected: onPageSelected,
                    );
                  },
                  icon: const Icon(Icons.grid_view_outlined),
                  label: Text(
                    strings.actions.showGroup(count: pageCount),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  tooltip: strings.tooltips.delete,
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () {
                    _dismissKeyboard();
                    controller.removeDocAt(currentIndex);
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
