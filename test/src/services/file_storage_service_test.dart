import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../helpers/temp_file_storage.dart';

void main() {
  late TempFileStorage storage;

  setUp(() async => storage = await TempFileStorage.create());
  tearDown(() => storage.dispose());

  group('resolveAbsolutePath', () {
    test('joins the relative path onto the documents folder', () async {
      expect(
        await storage.resolveAbsolutePath(p.join('docs', 'a.jpg')),
        p.join(storage.root.path, 'docs', 'a.jpg'),
      );
    });
  });

  group('ensureDirectory', () {
    test('creates nested folders', () async {
      final dir = await storage.ensureDirectory(['a', 'b', 'c']);

      expect(dir.path, storage.pathOf(p.join('a', 'b', 'c')));
      expect(await dir.exists(), isTrue);
    });

    test('leaves an existing folder and its contents alone', () async {
      await storage.write(p.join('a', 'keep.txt'), 'kept');

      await storage.ensureDirectory(['a']);

      expect(
        await File(storage.pathOf(p.join('a', 'keep.txt'))).readAsString(),
        'kept',
      );
    });
  });

  group('saveFile', () {
    test('copies into the folder under the new name, keeping the extension',
        () async {
      final source = await storage.write('scan.jpg', 'image');

      final saved = await storage.saveFile(
        sourcePath: source,
        targetSubDirectories: ['docs', 'g1'],
        fileNameWithoutExtension: 'Page 1',
      );

      expect(saved.relativePath, p.join('docs', 'g1', 'Page 1.jpg'));
      expect(saved.absolutePath, storage.pathOf(saved.relativePath));
      expect(await File(saved.absolutePath).readAsString(), 'image');
    });

    test('leaves the source in place', () async {
      final source = await storage.write('scan.jpg', 'image');

      await storage.saveFile(
        sourcePath: source,
        targetSubDirectories: ['docs'],
        fileNameWithoutExtension: 'Page',
      );

      expect(await File(source).exists(), isTrue);
    });

    test('a missing source throws and creates nothing', () async {
      await expectLater(
        storage.saveFile(
          sourcePath: storage.pathOf('missing.jpg'),
          targetSubDirectories: ['docs'],
          fileNameWithoutExtension: 'Page',
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(await Directory(storage.pathOf('docs')).exists(), isFalse);
    });

    // Why UniqueNameAllocator exists: the copy overwrites silently.
    test('silently overwrites a file already at the target', () async {
      await storage.write(p.join('docs', 'Page.jpg'), 'old');
      final source = await storage.write('scan.jpg', 'new');

      final saved = await storage.saveFile(
        sourcePath: source,
        targetSubDirectories: ['docs'],
        fileNameWithoutExtension: 'Page',
      );

      expect(await File(saved.absolutePath).readAsString(), 'new');
    });
  });

  group('listEntryNames', () {
    test('is empty for a folder that does not exist', () async {
      expect(await storage.listEntryNames(['nope']), isEmpty);
    });

    test('lists files and folders directly inside, not deeper', () async {
      await storage.write(p.join('docs', 'a.jpg'), '');
      await storage.write(p.join('docs', 'g1', 'deep.jpg'), '');

      expect(await storage.listEntryNames(['docs']), {'a.jpg', 'g1'});
    });
  });

  group('rename', () {
    test('moves a file', () async {
      final from = await storage.write('a.txt', 'a');
      final to = storage.pathOf('b.txt');

      await storage.rename(from, to);

      expect(await File(from).exists(), isFalse);
      expect(await File(to).readAsString(), 'a');
    });

    test('moves a folder with its contents', () async {
      await storage.write(p.join('old', 'a.txt'), 'a');

      await storage.rename(storage.pathOf('old'), storage.pathOf('new'));

      expect(
        await File(storage.pathOf(p.join('new', 'a.txt'))).readAsString(),
        'a',
      );
      expect(await Directory(storage.pathOf('old')).exists(), isFalse);
    });

    test('throws when there is nothing to move', () async {
      await expectLater(
        storage.rename(storage.pathOf('missing'), storage.pathOf('x')),
        throwsA(isA<FileSystemException>()),
      );
    });

    // Why moveAllViaStaging exists: a rename onto a taken name overwrites.
    test('onto an existing file, replaces it', () async {
      final from = await storage.write('a.txt', 'a');
      final to = await storage.write('b.txt', 'b');

      await storage.rename(from, to);

      expect(await File(to).readAsString(), 'a');
    });
  });

  group('delete', () {
    test('removes a file', () async {
      final file = await storage.write('a.txt', 'a');

      await storage.delete(file);

      expect(await File(file).exists(), isFalse);
    });

    test('removes a folder and everything in it', () async {
      await storage.write(p.join('g1', 'a.txt'), 'a');

      await storage.delete(storage.pathOf('g1'));

      expect(await Directory(storage.pathOf('g1')).exists(), isFalse);
    });

    test('does nothing for a missing path', () async {
      await storage.delete(storage.pathOf('missing'));
    });
  });

  group('deleteQuietly', () {
    test('removes files and folders', () async {
      final file = await storage.write('a.txt', 'a');
      await storage.write(p.join('g1', 'b.txt'), 'b');

      storage
        ..deleteQuietly(file)
        ..deleteQuietly(storage.pathOf('g1'));

      expect(await File(file).exists(), isFalse);
      expect(await Directory(storage.pathOf('g1')).exists(), isFalse);
    });

    test('never throws', () {
      expect(() => storage.deleteQuietly(storage.pathOf('missing')),
          returnsNormally);
    });

    test('a batch carries on past paths that are missing', () async {
      final a = await storage.write('a.txt', 'a');
      final b = await storage.write('b.txt', 'b');

      storage.deleteQuietlyBatch([a, storage.pathOf('missing'), b]);

      expect(await File(a).exists(), isFalse);
      expect(await File(b).exists(), isFalse);
    });
  });
}