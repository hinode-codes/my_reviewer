import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/constants/ui_constants.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/hero_tags.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/constants/image_constants.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';
import 'package:my_reviewer/src/shared/ui/selection/selection_tile.dart';
import 'package:my_reviewer/src/shared/ui/stacked_thumbnail_cards/thumbnail_card.dart';

class DocsDocumentGridTile extends StatelessWidget {
  const DocsDocumentGridTile({
    super.key,
    required this._selection,
    required this._doc,
  });

  final SelectableItems<ScannedDocumentModel> _selection;
  final ScannedDocumentModel _doc;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: _selection,
      // Built once per tile build, not per selection change: only the
      // selection frame below depends on the selection.
      child: Column(
        children: [
          Expanded(
            child: Center(
              // Same page shape as the stack's cards. The Hero sits inside
              // the AspectRatio so its rect is the card itself, not the
              // whole cell, and the flight from the stack lands on it.
              child: AspectRatio(
                aspectRatio: ImageConstants.defaultCardAspectRatio,
                child: Hero(
                  tag: pageHeroTag(_doc.groupId, _doc.relativePath),
                  transitionOnUserGestures: true,
                  child: ThumbnailCard(path: _doc.relativePath),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _doc.name,
            style: textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat(DocsUiConstants.dateTimePattern).format(_doc.createdAt),
            style: textTheme.bodySmall,
          ),
        ],
      ),
      builder: (context, child) {
        return SelectionTile(
          selection: _selection.selectionOf(_doc),
          onTap: () {
            switch (_selection.tap(_doc)) {
              case SelectionTap.openItem:
                DocsPageViewerRouteData(
                  docId: _doc.id,
                  groupId: _doc.groupId,
                  $extra: _selection.items,
                ).push(context);
                break;
              case SelectionTap.toggled:
                break;
            }
          },
          onLongPress: () {
            _selection.longPress(_doc);
          },
          child: child!,
        );
      },
    );
  }
}
