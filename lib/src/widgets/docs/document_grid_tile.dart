import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';
import 'package:my_reviewer/src/constants/stack_constants.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/utils/hero_tags.dart';
import 'package:my_reviewer/src/widgets/common/misc/thumbnail/thumbnail_card.dart';
import 'package:my_reviewer/src/widgets/common/selection/selection_tile.dart';

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
                aspectRatio: StackConstants.defaultCardAspectRatio,
                child: Hero(
                  tag: pageHeroTag(_doc.groupId, _doc.absoluteFilePath),
                  transitionOnUserGestures: true,
                  child: ThumbnailCard(path: _doc.absoluteFilePath),
                ),
              ),
            ),
          ),
          const SizedBox(height: DocsUiConstants.spacingSmall),
          Text(
            _doc.name,
            style: textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: DocsUiConstants.spacingTiny),
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
            _selection.tap(_doc);
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
