import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_preview_controller.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/ui/text_field/name_text_field.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';
import 'package:provider/provider.dart';

import 'scan_thumbnail_card.dart';

class ScanPreviewBottomSheet extends StatelessWidget {
  const ScanPreviewBottomSheet({super.key, required this.onPageSelected});

  final ValueChanged<int> onPageSelected;

  /// Opens the sheet.
  ///
  /// A modal sheet is built in the navigator's overlay, outside the subtree
  /// that holds the screen's [ScanPreviewController] provider. The controller is
  /// therefore re-exposed to the sheet here, which is what lets the sheet
  /// `watch` it and rebuild when the group name changes.
  static Future<void> show(
    BuildContext context, {
    required ScanPreviewController controller,
    required ValueChanged<int> onPageSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
      ),
      builder: (_) {
        return ChangeNotifierProvider<ScanPreviewController>.value(
          value: controller,
          child: ScanPreviewBottomSheet(onPageSelected: onPageSelected),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ScanPreviewController>();
    final docs = controller.pages;
    final imagePaths = controller.imagePaths;
    final strings = t.docs.scan.preview.bottomSheet;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close_outlined),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          NameTextField(
            initialValue: controller.groupName,
            labelText: strings.fields.groupName.label,
            hintText: strings.fields.groupName.placeholder,
            errorText: switch (controller.groupNameValidation) {
              NameValidation.valid => null,
              NameValidation.empty => strings.fields.groupName.errors.empty,
            },
            onChanged: controller.updateGroupName,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.separated(
              itemCount: imagePaths.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => Center(
                child: ScanThumbnailCard(
                  imagePath: imagePaths[index],
                  name: index < docs.length ? docs[index].name : "",
                  pageNumber: index + 1,
                  emphasis: index == controller.currentIndex
                      ? ThumbnailEmphasis.selected
                      : ThumbnailEmphasis.normal,
                  onTap: () {
                    onPageSelected(index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
