import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/controllers/selection/items_feed.dart';
import 'package:my_reviewer/src/models/selection_state.dart';

import '../../../helpers/notification_counter.dart';

void main() {
  // Synchronous, so an add() is delivered before the next line runs.
  late StreamController<List<String>> source;

  setUp(() => source = StreamController<List<String>>(sync: true));
  tearDown(() => source.close());

  group('ItemsFeed', () {
    test('without initial items it is loading and empty', () {
      final feed = ItemsFeed<String>(source.stream);
      addTearDown(feed.dispose);

      expect(feed.itemsStatus, ItemsStatus.loading);
      expect(feed.items, isEmpty);
    });

    test('initial items make it ready at once', () {
      final feed = ItemsFeed<String>(source.stream, initialItems: ['a', 'b']);
      addTearDown(feed.dispose);

      expect(feed.itemsStatus, ItemsStatus.ready);
      expect(feed.items, ['a', 'b']);
    });

    test('an emission makes it ready with those items, notifying once', () {
      final feed = ItemsFeed<String>(source.stream);
      addTearDown(feed.dispose);
      final notifications = NotificationCounter(feed);
      addTearDown(notifications.dispose);

      source.add(['a', 'b']);

      expect(feed.itemsStatus, ItemsStatus.ready);
      expect(feed.items, ['a', 'b']);
      expect(notifications.count, 1);
    });

    test('a stream error marks it failed and keeps the error', () {
      final feed = ItemsFeed<String>(source.stream);
      addTearDown(feed.dispose);
      final error = StateError('query failed');

      source.addError(error);

      expect(feed.itemsStatus, ItemsStatus.failed);
      expect(feed.itemsError, same(error));
    });

    test('an emission after an error recovers and clears the error', () {
      final feed = ItemsFeed<String>(source.stream);
      addTearDown(feed.dispose);

      source.addError(StateError('query failed'));
      source.add(['a']);

      expect(feed.itemsStatus, ItemsStatus.ready);
      expect(feed.itemsError, isNull);
      expect(feed.items, ['a']);
    });

    test('later changes to the emitted list do not leak in', () {
      final feed = ItemsFeed<String>(source.stream);
      addTearDown(feed.dispose);
      final emitted = ['a'];

      source.add(emitted);
      emitted.add('b');

      expect(feed.items, ['a']);
    });

    test('items cannot be modified from outside', () {
      final feed = ItemsFeed<String>(source.stream, initialItems: ['a']);
      addTearDown(feed.dispose);

      expect(() => feed.items.add('b'), throwsUnsupportedError);
    });

    test('items is the same list until the feed emits again', () {
      final feed = ItemsFeed<String>(source.stream, initialItems: ['a']);
      addTearDown(feed.dispose);

      expect(identical(feed.items, feed.items), isTrue);
    });

    test('dispose cancels the subscription', () {
      final feed = ItemsFeed<String>(source.stream);

      expect(source.hasListener, isTrue);

      feed.dispose();

      expect(source.hasListener, isFalse);
    });
  });
}