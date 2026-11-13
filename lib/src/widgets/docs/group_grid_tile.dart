import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';
import 'package:my_reviewer/src/constants/stack_constants.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/widgets/common/misc/thumbnail/stacked_thumbnail_card.dart';
import 'package:my_reviewer/src/widgets/common/selection/selection_tile.dart';

class DocsGroupGridTile extends StatelessWidget {
  const DocsGroupGridTile({
    super.key,
    required this._selection,
    required this._group,
  });

  final SelectableItems<ScannedDocumentGroupModel> _selection;
  final ScannedDocumentGroupModel _group;

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
            child: RepaintBoundary(
              key: ValueKey(_group.id),
              child: StackedThumbnailCard(
                heroPrefix: _group.id,
                imagePaths: _group.documents
                    .map((doc) => doc.absoluteFilePath)
                    .take(StackConstants.maxVisibleCards)
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: DocsUiConstants.spacingSmall),

          Text(
            _group.groupName,
            style: textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: DocsUiConstants.spacingTiny),

          Text(
            t.docs.main.documentCount(n: _group.documents.length),
            style: textTheme.bodySmall,
          ),

          const SizedBox(height: DocsUiConstants.spacingTiny),

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
                break;
              case SelectionTap.toggled:
                break;
            }
          },
          onLongPress: () {
            _selection.longPress(_group);
          },
          child: child!,
        );
      },
    );
  }
}
