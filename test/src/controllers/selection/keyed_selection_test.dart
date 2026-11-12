import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/controllers/selection/keyed_selection.dart';
import 'package:my_reviewer/src/models/selection_state.dart';

import '../../../helpers/notification_counter.dart';

typedef _Item = ({String id, String name});

const _Item _a = (id: 'a', name: 'A');
const _Item _b = (id: 'b', name: 'B');
const _Item _c = (id: 'c', name: 'C');
const _items = [_a, _b, _c];

KeyedSelection<_Item> _selection() => KeyedSelection<_Item>(keyOf: (i) => i.id);

void main() {
  late KeyedSelection<_Item> selection;
  late NotificationCounter notifications;

  setUp(() {
    selection = _selection();
    notifications = NotificationCounter(selection);
  });
  tearDown(() {
    notifications.dispose();
    selection.dispose();
  });

  group('inactive', () {
    test('starts inactive with nothing selectable', () {
      expect(selection.mode, SelectionMode.inactive);
      expect(selection.selectedCount, 0);
      expect(selection.selectionOf(_a), ItemSelection.unavailable);
    });

    test('a tap asks to open the item and changes nothing', () {
      expect(selection.tap(_a), SelectionTap.openItem);
      expect(selection.mode, SelectionMode.inactive);
      expect(notifications.count, 0);
    });

    test('a long press starts selecting with that item selected', () {
      selection.longPress(_b);

      expect(selection.mode, SelectionMode.active);
      expect(selection.selectionOf(_b), ItemSelection.selected);
      expect(selection.selectionOf(_a), ItemSelection.unselected);
      expect(notifications.count, 1);
    });

    test('entering without an item selects nothing', () {
      selection.enterSelectionMode();

      expect(selection.mode, SelectionMode.active);
      expect(selection.selectedCount, 0);
    });
  });

  group('active', () {
    setUp(() {
      selection.enterSelectionMode();
      notifications.reset();
    });

    test('a tap toggles the item and says so', () {
      expect(selection.tap(_a), SelectionTap.toggled);
      expect(selection.selectionOf(_a), ItemSelection.selected);

      expect(selection.tap(_a), SelectionTap.toggled);
      expect(selection.selectionOf(_a), ItemSelection.unselected);

      expect(notifications.count, 2);
    });

    test('a long press toggles too', () {
      selection.longPress(_a);
      expect(selection.selectionOf(_a), ItemSelection.selected);

      selection.longPress(_a);
      expect(selection.selectionOf(_a), ItemSelection.unselected);
    });

    test('selection follows the key, not the item instance', () {
      selection.toggle(_a);

      const renamed = (id: 'a', name: 'Renamed');
      expect(selection.selectionOf(renamed), ItemSelection.selected);
    });

    test('exiting clears the selection', () {
      selection.toggle(_a);
      selection.exitSelectionMode();

      expect(selection.mode, SelectionMode.inactive);
      expect(selection.selectedCount, 0);
      expect(selection.selectionOf(_a), ItemSelection.unavailable);
    });

    test('selected items come back in list order, not selection order', () {
      selection
        ..toggle(_c)
        ..toggle(_a);

      expect(selection.selectedIn(_items), [_a, _c]);
    });
  });

  group('coverage and select all', () {
    setUp(() => selection.enterSelectionMode());

    test('partial until every item is selected', () {
      selection.toggle(_a);
      expect(selection.coverageOf(_items), SelectionCoverage.partial);

      selection
        ..toggle(_b)
        ..toggle(_c);
      expect(selection.coverageOf(_items), SelectionCoverage.all);
    });

    test('select all from partial selects everything', () {
      selection
        ..toggle(_a)
        ..toggleSelectAll(_items);

      expect(selection.selectedCount, _items.length);
      expect(selection.coverageOf(_items), SelectionCoverage.all);
    });

    test('select all from all clears, but stays in selection mode', () {
      selection
        ..toggleSelectAll(_items)
        ..toggleSelectAll(_items);

      expect(selection.selectedCount, 0);
      expect(selection.mode, SelectionMode.active);
    });
  });

  group('retainPresent', () {
    setUp(() {
      selection
        ..enterSelectionMode()
        ..toggle(_a)
        ..toggle(_b);
      notifications.reset();
    });

    test('drops keys no longer in the list and notifies once', () {
      selection.retainPresent(const [_b, _c]);

      expect(selection.selectedIn(const [_a, _b, _c]), [_b]);
      expect(notifications.count, 1);
    });

    test('does not notify when nothing was dropped', () {
      selection.retainPresent(_items);

      expect(selection.selectedCount, 2);
      expect(notifications.count, 0);
    });
  });
}