import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/widgets/docs_screen/docs_group_tile.dart';

class DocsGridView extends StatelessWidget {
  const DocsGridView({super.key, required this.snapshot, required this.groups});

  final AsyncSnapshot<List<ScannedDocumentGroupModel>> snapshot;
  final List<ScannedDocumentGroupModel> groups;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Text(
          t.docs.main.snapshotError(error: snapshot.error.toString()),
        ),
      );
    }

    if (groups.isEmpty) {
      return Center(child: Text(t.docs.main.noDocs));
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GridView.builder(
      padding: const EdgeInsets.all(DocsUiConstants.paddingAll),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLandscape
            ? DocsUiConstants.gridLandscapeCrossAxisCount
            : DocsUiConstants.gridPortraitCrossAxisCount,
        mainAxisExtent: DocsUiConstants.gridMainAxisExtent,
        childAspectRatio: DocsUiConstants.gridChildAspectRatio,
        crossAxisSpacing: DocsUiConstants.gridSpacing,
        mainAxisSpacing: DocsUiConstants.gridSpacing,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];

        return DocsGroupTile(key: ValueKey(group.id), group: group);
      },
    );
  }
}
