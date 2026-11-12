import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/repositories/scanned_document/layout.dart';
import 'package:my_reviewer/src/utils/string.dart';
import 'package:my_reviewer/src/utils/unique_name_allocator.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/temp_file_storage.dart';

final _when = DateTime(2026);
const _root = ScannedDocumentLayout.rootFolder;

ScannedDocumentModel _doc(
  String id,
  String name, {
  String ext = 'jpg',
  String? currentFileName,
}) => ScannedDocumentModel(
  id: id,
  groupId: 'g1',
  name: name,
  relativeFilePath: p.join(_root, 'Group', currentFileName ?? 'scan_$id.$ext'),
  absoluteFilePath: '/unused/scan_$id.$ext',
  createdAt: _when,
  updatedAt: _when,
  ext: ext,
);

void main() {
  late TempFileStorage storage;
  late ScannedDocumentLayout layout;

  setUp(() async {
    storage = await TempFileStorage.create();
    layout = ScannedDocumentLayout(storage);
  });
  tearDown(() => storage.dispose());

  GroupFolder folderNamed(String name) {
    final relative = layout.relativeFolderPath(name);
    return (name: name, relative: relative, absolute: storage.pathOf(relative));
  }

  // Expected names go through the same sanitizer the layout uses, so these
  // tests pin the layout's own rules, not sanitizeFileName's.
  String clean(String name, String fallback) =>
      sanitizeFileName(name, fallback);

  group('paths', () {
    test('every group folder lives under the root folder', () {
      expect(layout.folderSegments('Biology'), [_root, 'Biology']);
      expect(layout.relativeFolderPath('Biology'), p.join(_root, 'Biology'));
    });

    test('staging paths sit inside the folder, hidden, one per document', () {
      final folder = folderNamed('Biology');

      final a = layout.stagingPathFor(folder, 'doc-a');
      final b = layout.stagingPathFor(folder, 'doc-b');

      expect(p.dirname(a), folder.absolute);
      expect(p.basename(a), startsWith('.'));
      expect(p.basename(a), contains('doc-a'));
      expect(a, isNot(b));
    });
  });

  group('claimFolderName', () {
    test('a free name is used as is, even before the root exists', () async {
      expect(
        await layout.claimFolderName('Biology', 'g1'),
        clean('Biology', 'g1'),
      );
    });

    test('a name another group uses gets a number', () async {
      final base = clean('Biology', 'g1');
      await storage.ensureDirectory([_root, base]);

      expect(await layout.claimFolderName('Biology', 'g1'), '${base}_2');
    });

    test("the group's own folder is not a collision", () async {
      final base = clean('Biology', 'g1');
      await storage.ensureDirectory([_root, base]);

      expect(
        await layout.claimFolderName('Biology', 'g1', current: base),
        base,
      );
    });

    test("renaming onto another group's name still gets a number", () async {
      final biology = clean('Biology', 'g1');
      final chemistry = clean('Chemistry', 'g1');
      await storage.ensureDirectory([_root, biology]);
      await storage.ensureDirectory([_root, chemistry]);

      expect(
        await layout.claimFolderName('Biology', 'g1', current: chemistry),
        '${biology}_2',
      );
    });

    test('an empty name falls back', () async {
      expect(await layout.claimFolderName('', 'g1'), clean('', 'g1'));
    });
  });

  group('planPages', () {
    test('places each page in the folder under its name and extension', () {
      final folder = folderNamed('Biology');

      final [page] = layout.planPages(
        [_doc('1', 'Cells', ext: 'png')],
        groupName: 'Biology',
        folder: folder,
        names: UniqueNameAllocator(const []),
      );
      final name = clean('Cells', 'unused');

      expect(page.fileNameWithoutExtension, name);
      expect(page.relativePath, p.join(folder.relative, '$name.png'));
      expect(page.absolutePath, p.join(folder.absolute, '$name.png'));
    });

    test('pages with the same name get numbered', () {
      final pages = layout.planPages(
        [_doc('1', 'Page'), _doc('2', 'Page')],
        groupName: 'Biology',
        folder: folderNamed('Biology'),
        names: UniqueNameAllocator(const []),
      );
      final base = clean('Page', 'unused');

      expect(pages.map((page) => page.fileNameWithoutExtension), [
        base,
        '${base}_2',
      ]);
    });

    test('the same name with different extensions does not collide', () {
      final pages = layout.planPages(
        [_doc('1', 'Page', ext: 'jpg'), _doc('2', 'Page', ext: 'png')],
        groupName: 'Biology',
        folder: folderNamed('Biology'),
        names: UniqueNameAllocator(const []),
      );

      expect(
        pages[0].fileNameWithoutExtension,
        pages[1].fileNameWithoutExtension,
      );
      expect(pages[0].relativePath, isNot(pages[1].relativePath));
    });

    test('a shared allocator keeps existing and new pages apart', () {
      final folder = folderNamed('Biology');
      final names = UniqueNameAllocator(const []);

      final [existing] = layout.planPages(
        [_doc('1', 'Page')],
        groupName: 'Biology',
        folder: folder,
        names: names,
      );
      final [added] = layout.planPages(
        [_doc('2', 'Page')],
        groupName: 'Biology',
        folder: folder,
        names: names,
        indexOffset: 1,
      );

      expect(added.relativePath, isNot(existing.relativePath));
    });

    test('unnamed pages fall back to names numbered after earlier pages', () {
      final pages = layout.planPages(
        [_doc('1', ''), _doc('2', '')],
        groupName: 'Biology',
        folder: folderNamed('Biology'),
        names: UniqueNameAllocator(const []),
        indexOffset: 3,
      );

      expect(pages.map((page) => page.fileNameWithoutExtension), [
        clean('', ScannedDocumentModel.fallbackFileName('Biology', 3)),
        clean('', ScannedDocumentModel.fallbackFileName('Biology', 4)),
      ]);
    });

    test('knows whether a page changes name', () {
      final base = clean('Page', 'unused');
      final [unchanged, renamed] = layout.planPages(
        [
          _doc('1', 'Page', currentFileName: '$base.jpg'),
          _doc('2', 'Notes', currentFileName: 'scan_2.jpg'),
        ],
        groupName: 'Biology',
        folder: folderNamed('Group'),
        names: UniqueNameAllocator(const []),
      );

      expect(
        unchanged.currentFileNameWithExtension,
        unchanged.targetFileNameWithExtension,
      );
      expect(renamed.currentFileNameWithExtension, 'scan_2.jpg');
      expect(
        renamed.targetFileNameWithExtension,
        '${clean('Notes', 'unused')}.jpg',
      );
    });
  });
}