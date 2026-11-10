import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs_scan_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/utils/string.dart';
import 'package:my_reviewer/src/widgets/docs_scan_screen/docs_scan_thumbnail_card.dart';
import 'package:my_reviewer/src/widgets/name_text_field.dart';
import 'package:provider/provider.dart';

/// Lets the user rename the scan group and jump to any of its pages.
class DocsScanGroupBottomSheet extends StatelessWidget {
  const DocsScanGroupBottomSheet({super.key, required this.onPageSelected});

  /// Called with the index of the tapped page, before the sheet closes.
  final ValueChanged<int> onPageSelected;

  /// Opens the sheet.
  ///
  /// A modal sheet is built in the navigator's overlay, outside the subtree
  /// that holds the screen's [DocsScanController] provider. The controller is
  /// therefore re-exposed to the sheet here, which is what lets the sheet
  /// `watch` it and rebuild when the group name changes.
  static Future<void> show(
    BuildContext context, {
    required ValueChanged<int> onPageSelected,
  }) {
    final scanController = context.read<DocsScanController>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
      ),
      builder: (_) {
        return ChangeNotifierProvider<DocsScanController>.value(
          value: scanController,
          child: DocsScanGroupBottomSheet(onPageSelected: onPageSelected),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanController = context.watch<DocsScanController>();
    final docs = scanController.scannedDocs;
    final imagePaths = scanController.tempImagePaths;
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
            initialValue: scanController.groupName,
            labelText: strings.groupNameLabel,
            hintText: strings.groupNamePlaceholder,
            errorText: switch (scanController.groupNameValidation) {
              NameValidation.valid => null,
              NameValidation.empty => strings.groupNameError,
            },
            onChanged: scanController.updateGroupName,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              itemCount: imagePaths.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                return Center(
                  child: DocsScanThumbnailCard(
                    imagePath: imagePaths[index],
                    name: index < docs.length ? docs[index].name : '',
                    pageNumber: index + 1,
                    emphasis: index == scanController.currentIndex
                        ? ThumbnailEmphasis.selected
                        : ThumbnailEmphasis.normal,
                    onTap: () {
                      onPageSelected(index);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
