import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';

/// A live, read-only list fed by a stream.
///
/// Owns only the subscription and its status. It knows nothing about
/// selection or deletion, so any screen that shows a stream of items can
/// compose it.
class ItemsFeed<T> extends ChangeNotifier {
  ItemsFeed(Stream<List<T>> items, {List<T>? initialItems})
    : _items = List.unmodifiable(initialItems ?? const []),
      // Seeded items let the first frame show the grid instead of a
      // spinner, which is what gives a Hero something to land on.
      _itemsStatus = initialItems == null
          ? ItemsStatus.loading
          : ItemsStatus.ready {
    // Subscribed once for the feed's lifetime, so rebuilding the screen
    // never re-subscribes and flashes the loading state.
    _subscription = items.listen(_onItems, onError: _onItemsError);
  }

  late final StreamSubscription<List<T>> _subscription;

  List<T> _items;
  List<T> get items => _items;

  ItemsStatus _itemsStatus;
  ItemsStatus get itemsStatus => _itemsStatus;

  Object? _itemsError;
  Object? get itemsError => _itemsError;

  void _onItems(List<T> items) {
    _items = List.unmodifiable(items);
    _itemsStatus = ItemsStatus.ready;
    _itemsError = null;

    notifyListeners();
  }

  void _onItemsError(Object error) {
    _itemsStatus = ItemsStatus.failed;
    _itemsError = error;

    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
