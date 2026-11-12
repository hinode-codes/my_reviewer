import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/models/selection_state.dart';

import 'items_feed.dart';
import 'keyed_selection.dart';

/// A live list of items that can be multi-selected.
///
/// Owns the one invariant that ties the two parts together: the selection
/// only ever holds keys of items that are currently in the list. Feature
/// controllers hold one of these (has-a) instead of extending it, which is
/// why it is final.
final class SelectableItems<T> extends ChangeNotifier {
  SelectableItems({
    required Stream<List<T>> items,
    required String Function(T item) keyOf,
    List<T>? initialItems,
  }) : _feed = ItemsFeed<T>(items, initialItems: initialItems),
       _selection = KeyedSelection<T>(keyOf: keyOf) {
    _feed.addListener(_onFeedChanged);
    _selection.addListener(notifyListeners);
  }

  final ItemsFeed<T> _feed;
  final KeyedSelection<T> _selection;

  List<T> get items => _feed.items;
  ItemsStatus get itemsStatus => _feed.itemsStatus;
  Object? get itemsError => _feed.itemsError;

  SelectionMode get mode => _selection.mode;
  int get totalCount => _feed.items.length;
  int get selectedCount => _selection.selectedCount;
  SelectionCoverage get coverage => _selection.coverageOf(_feed.items);

  /// The selected items, in list order.
  List<T> get selectedItems => _selection.selectedIn(_feed.items);

  ItemSelection selectionOf(T item) => _selection.selectionOf(item);

  void enterSelectionMode([T? initial]) =>
      _selection.enterSelectionMode(initial);

  void exitSelectionMode() => _selection.exitSelectionMode();

  void toggle(T item) => _selection.toggle(item);

  void toggleSelectAll() => _selection.toggleSelectAll(_feed.items);

  SelectionTap tap(T item) => _selection.tap(item);

  void longPress(T item) => _selection.longPress(item);

  void _onFeedChanged() {
    final selectedBefore = _selection.selectedCount;

    // After a partial delete failure the already-deleted keys would stay
    // selected; Retry would then ask for rows that no longer exist, the
    // repository would throw, and Retry could never succeed.
    _selection.retainPresent(_feed.items);

    // retainPresent notifies (relayed above) only when it pruned something.
    // Notifying again here would send two notifications for one update.
    if (_selection.selectedCount == selectedBefore) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Disposing the parts also drops the listeners registered above.
    _feed.dispose();
    _selection.dispose();
    super.dispose();
  }
}