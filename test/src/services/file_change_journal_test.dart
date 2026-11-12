import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/services/file_change_journal.dart';
import 'package:path/path.dart' as p;

import '../../helpers/temp_file_storage.dart';

void main() {
  late TempFileStorage storage;
  late FileChangeJournal journal;

  setUp(() async {
    storage = await TempFileStorage.create();
    journal = FileChangeJournal(storage);
  });
  tearDown(() => storage.dispose());

  Future<String?> read(String relative) async {
    final file = File(storage.pathOf(relative));
    return await file.exists() ? file.readAsString() : null;
  }

  group('move', () {
    test('renames on disk', () async {
      await storage.write('a.txt', 'a');

      await journal.move(storage.pathOf('a.txt'), storage.pathOf('b.txt'));

      expect(await read('a.txt'), isNull);
      expect(await read('b.txt'), 'a');
    });

    test('a move that fails is not recorded, so rollback skips it', () async {
      await expectLater(
        journal.move(storage.pathOf('missing'), storage.pathOf('x')),
        throwsA(isA<FileSystemException>()),
      );

      await journal.rollback();
    });
  });

  group('rollback', () {
    test('undoes a move', () async {
      await storage.write('a.txt', 'a');
      await journal.move(storage.pathOf('a.txt'), storage.pathOf('b.txt'));

      await journal.rollback();

      expect(await read('a.txt'), 'a');
      expect(await read('b.txt'), isNull);
    });

    test('undoes a chain of moves in reverse', () async {
      await storage.write('a.txt', 'a');
      await journal.move(storage.pathOf('a.txt'), storage.pathOf('b.txt'));
      await journal.move(storage.pathOf('b.txt'), storage.pathOf('c.txt'));

      await journal.rollback();

      expect(await read('a.txt'), 'a');
      expect(await read('b.txt'), isNull);
      expect(await read('c.txt'), isNull);
    });

    test('deletes recorded new files', () async {
      final created = await storage.write('new.jpg', 'copy');
      journal.recordCreated(created);

      await journal.rollback();

      expect(await File(created).exists(), isFalse);
    });

    test('deletes new files inside a moved folder before moving it back',
        () async {
      await storage.write(p.join('old', 'page.jpg'), 'page');
      await journal.move(storage.pathOf('old'), storage.pathOf('new'));
      journal.recordCreated(
        await storage.write(p.join('new', 'added.jpg'), 'added'),
      );

      await journal.rollback();

      expect(await read(p.join('old', 'page.jpg')), 'page');
      expect(await read(p.join('old', 'added.jpg')), isNull);
      expect(await Directory(storage.pathOf('new')).exists(), isFalse);
    });

    test('carries on when one undo fails', () async {
      await storage.write('a.txt', 'a');
      await storage.write('b.txt', 'b');
      await journal.move(storage.pathOf('a.txt'), storage.pathOf('a2.txt'));
      await journal.move(storage.pathOf('b.txt'), storage.pathOf('b2.txt'));
      // Something else removed a2.txt, so undoing the first move fails.
      await File(storage.pathOf('a2.txt')).delete();

      await journal.rollback();

      expect(await read('b.txt'), 'b');
    });

    test('with nothing recorded, does nothing', () async {
      await storage.write('a.txt', 'a');

      await journal.rollback();

      expect(await read('a.txt'), 'a');
    });
  });

  group('moveAllViaStaging', () {
    StagedMove staged(String from, String to) => (
      from: storage.pathOf(from),
      staging: storage.pathOf('.renaming_$from'),
      to: storage.pathOf(to),
    );

    test('two files can trade names without losing either', () async {
      await storage.write('a.jpg', 'A');
      await storage.write('b.jpg', 'B');

      await journal.moveAllViaStaging([
        staged('a.jpg', 'b.jpg'),
        staged('b.jpg', 'a.jpg'),
      ], onEachFinalMove: () {});

      expect(await read('a.jpg'), 'B');
      expect(await read('b.jpg'), 'A');
    });

    test('a file can take a name another file gives up later in the batch',
        () async {
      await storage.write('page_2.jpg', 'second');
      await storage.write('page_3.jpg', 'third');

      await journal.moveAllViaStaging([
        staged('page_3.jpg', 'page_2.jpg'),
        staged('page_2.jpg', 'page_1.jpg'),
      ], onEachFinalMove: () {});

      expect(await read('page_1.jpg'), 'second');
      expect(await read('page_2.jpg'), 'third');
      expect(await read('page_3.jpg'), isNull);
    });

    test('leaves no staging files behind', () async {
      await storage.write('a.jpg', 'A');

      await journal.moveAllViaStaging([
        staged('a.jpg', 'b.jpg'),
      ], onEachFinalMove: () {});

      expect(await storage.listEntryNames([]), {'b.jpg'});
    });

    test('reports each final move', () async {
      await storage.write('a.jpg', 'A');
      await storage.write('b.jpg', 'B');
      var reported = 0;

      await journal.moveAllViaStaging([
        staged('a.jpg', 'x.jpg'),
        staged('b.jpg', 'y.jpg'),
      ], onEachFinalMove: () => reported++);

      expect(reported, 2);
    });

    test('rollback puts a swap back exactly', () async {
      await storage.write('a.jpg', 'A');
      await storage.write('b.jpg', 'B');
      await journal.moveAllViaStaging([
        staged('a.jpg', 'b.jpg'),
        staged('b.jpg', 'a.jpg'),
      ], onEachFinalMove: () {});

      await journal.rollback();

      expect(await read('a.jpg'), 'A');
      expect(await read('b.jpg'), 'B');
      expect(await storage.listEntryNames([]), {'a.jpg', 'b.jpg'});
    });

    test('rollback after a failure halfway restores the files moved so far',
        () async {
      await storage.write('a.jpg', 'A');

      await expectLater(
        journal.moveAllViaStaging([
          staged('a.jpg', 'x.jpg'),
          staged('missing.jpg', 'y.jpg'),
        ], onEachFinalMove: () {}),
        throwsA(isA<FileSystemException>()),
      );
      await journal.rollback();

      expect(await storage.listEntryNames([]), {'a.jpg'});
      expect(await read('a.jpg'), 'A');
    });
  });
}