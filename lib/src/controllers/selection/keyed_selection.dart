import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/models/selection_state.dart';

/// Multi-select state over items identified by a string key.
///
/// It does not own the items. Operations that need the current list take it
/// as an argument, so it can sit next to any source of items.
class KeyedSelection<T> extends ChangeNotifier {
  KeyedSelection({required this._keyOf});

  final String Function(T item) _keyOf;

  SelectionMode _mode = SelectionMode.inactive;
  SelectionMode get mode => _mode;

  final Set<String> _selectedKeys = {};
  int get selectedCount => _selectedKeys.length;

  SelectionCoverage coverageOf(List<T> items) =>
      _selectedKeys.length == items.length
      ? SelectionCoverage.all
      : SelectionCoverage.partial;

  ItemSelection selectionOf(T item) => switch (_mode) {
    SelectionMode.inactive => ItemSelection.unavailable,
    SelectionMode.active =>
      _selectedKeys.contains(_keyOf(item))
          ? ItemSelection.selected
          : ItemSelection.unselected,
  };

  /// The selected items, in the order they appear in [items].
  List<T> selectedIn(List<T> items) => [
    for (final item in items)
      if (_selectedKeys.contains(_keyOf(item))) item,
  ];

  void enterSelectionMode([T? initial]) {
    _mode = SelectionMode.active;

    if (initial != null) {
      _selectedKeys.add(_keyOf(initial));
    }

    notifyListeners();
  }

  void exitSelectionMode() {
    _mode = SelectionMode.inactive;
    _selectedKeys.clear();

    notifyListeners();
  }

  void toggle(T item) {
    final key = _keyOf(item);

    if (!_selectedKeys.remove(key)) {
      _selectedKeys.add(key);
    }

    notifyListeners();
  }

  void toggleSelectAll(List<T> items) {
    switch (coverageOf(items)) {
      case SelectionCoverage.all:
        _selectedKeys.clear();
      case SelectionCoverage.partial:
        _selectedKeys.addAll(items.map(_keyOf));
    }

    notifyListeners();
  }

  SelectionTap tap(T item) {
    switch (_mode) {
      case SelectionMode.inactive:
        return SelectionTap.openItem;
      case SelectionMode.active:
        toggle(item);
        
        return SelectionTap.toggled;
    }
  }

  void longPress(T item) {
    switch (_mode) {
      case SelectionMode.inactive:
        enterSelectionMode(item);
      case SelectionMode.active:
        toggle(item);
    }
  }

  /// Drops selected keys that are no longer in [items].
  void retainPresent(List<T> items) {
    final before = _selectedKeys.length;
    final present = {for (final item in items) _keyOf(item)};
    _selectedKeys.retainWhere(present.contains);

    if (_selectedKeys.length != before) {
      notifyListeners();
    }
  }
}