import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:provider/provider.dart';

class DocsGridView<T> extends StatelessWidget {
  const DocsGridView({
    super.key,
    required this._selection,
    required this._emptyMessage,
    required this._tileBuilder,
  });

  final SelectableItems<T> _selection;
  final String _emptyMessage;
  final Widget Function(BuildContext context, T item) _tileBuilder;

  @override
  Widget build(BuildContext context) {
    // Provided here so the body can `select` from it: callers keep passing
    // the selection in, and nothing above the grid has to change.
    return ListenableProvider<SelectableItems<T>>.value(
      value: _selection,
      child: _GridBody<T>(
        emptyMessage: _emptyMessage,
        tileBuilder: _tileBuilder,
      ),
    );
  }
}

/// What the grid shows. Records compare field by field, and `items` by
/// identity, so this changes only when the list itself is replaced.
typedef _GridView<T> = ({
  ItemsStatus status,
  List<T> items,
  int totalCount,
  Object? error,
});

class _GridBody<T> extends StatelessWidget {
  const _GridBody({required this.emptyMessage, required this.tileBuilder});

  final String emptyMessage;
  final Widget Function(BuildContext context, T item) tileBuilder;

  @override
  Widget build(BuildContext context) {
    // Selecting a toggle changes none of these, so the grid and its tiles
    // are not rebuilt by selection; each tile's own frame updates instead.
    final view = context.select<SelectableItems<T>, _GridView<T>>(
      (s) => (
        status: s.itemsStatus,
        items: s.items,
        totalCount: s.totalCount,
        error: s.itemsError,
      ),
    );

    return switch (view.status) {
      ItemsStatus.loading => Center(
        child: CircularProgressIndicator.adaptive(
          semanticsLabel: t.common.status.loading,
        ),
      ),
      ItemsStatus.failed => _Message(
        t.docs.main.snapshotError(error: view.error.toString()),
      ),
      ItemsStatus.ready when view.items.isEmpty => _Message(emptyMessage),
      ItemsStatus.ready => _grid(context, view),
    };
  }

  Widget _grid(BuildContext context, _GridView<T> view) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return GridView.builder(
      padding: const EdgeInsets.all(DocsUiConstants.paddingAll),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLandscape
            ? DocsUiConstants.gridLandscapeCrossAxisCount
            : DocsUiConstants.gridPortraitCrossAxisCount,
        childAspectRatio: DocsUiConstants.gridChildAspectRatio,
        crossAxisSpacing: DocsUiConstants.gridSpacing,
        mainAxisSpacing: DocsUiConstants.gridSpacing,
      ),
      itemCount: view.totalCount,
      itemBuilder: (context, index) => tileBuilder(context, view.items[index]),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DocsUiConstants.messagePaddingHorizontal,
      ),
      child: Center(child: Text(text)),
    );
  }
}