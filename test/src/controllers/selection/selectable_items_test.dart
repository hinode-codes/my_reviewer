import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/models/selection_state.dart';

import '../../../helpers/notification_counter.dart';

typedef _Item = ({String id, String name});

const _Item _a = (id: 'a', name: 'A');
const _Item _b = (id: 'b', name: 'B');
const _Item _c = (id: 'c', name: 'C');

void main() {
  late StreamController<List<_Item>> source;
  late SelectableItems<_Item> items;
  late NotificationCounter notifications;

  setUp(() {
    source = StreamController<List<_Item>>(sync: true);
    items = SelectableItems<_Item>(items: source.stream, keyOf: (i) => i.id);
    notifications = NotificationCounter(items);
  });
  tearDown(() async {
    notifications.dispose();
    items.dispose();
    await source.close();
  });

  test('exposes the feed: loading, then ready with the items', () {
    expect(items.itemsStatus, ItemsStatus.loading);

    source.add(const [_a, _b]);

    expect(items.itemsStatus, ItemsStatus.ready);
    expect(items.items, const [_a, _b]);
    expect(items.totalCount, 2);
  });

  test('exposes a stream error as failed', () {
    final error = StateError('query failed');

    source.addError(error);

    expect(items.itemsStatus, ItemsStatus.failed);
    expect(items.itemsError, same(error));
  });

  test('initial items make it ready before the stream emits', () {
    final seeded = SelectableItems<_Item>(
      items: const Stream.empty(),
      keyOf: (i) => i.id,
      initialItems: const [_a],
    );
    addTearDown(seeded.dispose);

    expect(seeded.itemsStatus, ItemsStatus.ready);
    expect(seeded.items, const [_a]);
  });

  test('selected items follow the current list order', () {
    source.add(const [_a, _b, _c]);
    items
      ..enterSelectionMode(_c)
      ..toggle(_a);

    expect(items.selectedItems, const [_a, _c]);
  });

  test('select all uses the current list', () {
    source.add(const [_a, _b]);
    items
      ..enterSelectionMode()
      ..toggleSelectAll();

    expect(items.selectedCount, 2);
    expect(items.coverage, SelectionCoverage.all);
  });

  group('keeping the selection in step with the list', () {
    setUp(() {
      source.add(const [_a, _b, _c]);
      items
        ..enterSelectionMode(_a)
        ..toggle(_b);
      notifications.reset();
    });

    test('an item that disappears is dropped from the selection', () {
      source.add(const [_b, _c]);

      expect(items.selectedCount, 1);
      expect(items.selectedItems, const [_b]);
    });

    test('one list update that prunes the selection notifies once', () {
      source.add(const [_b, _c]);

      expect(notifications.count, 1);
    });

    test('one list update that prunes nothing notifies once', () {
      source.add(const [_a, _b, _c]);

      expect(notifications.count, 1);
    });

    test('the selection survives a list update for the same keys', () {
      source.add(const [(id: 'a', name: 'Renamed'), _b, _c]);

      expect(items.selectedCount, 2);
      expect(items.mode, SelectionMode.active);
    });
  });

  test('selection changes are relayed', () {
    source.add(const [_a]);
    notifications.reset();

    items.enterSelectionMode(_a);

    expect(notifications.count, 1);
  });

  test('dispose cancels the stream subscription', () {
    final local = StreamController<List<_Item>>(sync: true);
    final disposable = SelectableItems<_Item>(
      items: local.stream,
      keyOf: (i) => i.id,
    );

    expect(local.hasListener, isTrue);

    disposable.dispose();

    expect(local.hasListener, isFalse);
    unawaited(local.close());
  });
}