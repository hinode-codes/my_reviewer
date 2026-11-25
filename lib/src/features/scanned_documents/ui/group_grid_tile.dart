import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/constants/ui_constants.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/hero_tags.dart';
import 'package:my_reviewer/src/locators/main_locator.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/constants/stack_constants.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:my_reviewer/src/shared/ui/selection/selection_tile.dart';
import 'package:my_reviewer/src/shared/ui/stacked_thumbnail_cards/stacked_thumbnail_card.dart';

class DocsGroupGridTile extends StatelessWidget {
  DocsGroupGridTile({
    super.key,
    required this._selection,
    required this._group,
    IFileStorageService? storageService,
  }) : _storageService = storageService ?? getIt<IFileStorageService>();

  final SelectableItems<ScannedDocumentGroupModel> _selection;
  final ScannedDocumentGroupModel _group;
  final IFileStorageService _storageService;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visibleDocs = _group.documents.take(StackConstants.maxVisibleCards);

    return ListenableBuilder(
      listenable: _selection,
      // Built once per tile build, not per selection change: only the
      // selection frame below depends on the selection.
      child: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: ValueKey(_group.id),
              child: StackedThumbnailCard(
                heroTags: [
                  for (final doc in visibleDocs)
                    pageHeroTag(doc.groupId, doc.relativePath),
                ],
                imagePaths: [
                  for (final doc in visibleDocs)
                    _storageService.resolveAbsolutePath(doc.relativePath),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _group.name,
            style: textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.docs.main.status.documentCount(n: _group.documents.length),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat(DocsUiConstants.dateTimePattern)
                .format(_group.createdAt),
            style: textTheme.bodySmall,
          ),
        ],
      ),
      builder: (context, child) {
        return SelectionTile(
          selection: _selection.selectionOf(_group),
          onTap: () {
            switch (_selection.tap(_group)) {
              case SelectionTap.openItem:
                DocsGroupRouteData(
                  groupId: _group.id,
                  $extra: _group.documents,
                ).push(context);
              case SelectionTap.toggled:
                break;
            }
          },
          onLongPress: () => _selection.longPress(_group),
          child: child!,
        );
      },
    );
  }
}
