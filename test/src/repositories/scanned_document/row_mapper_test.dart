import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/dao/docs_dao.dart';
import 'package:my_reviewer/src/repositories/scanned_document/row_mapper.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/temp_file_storage.dart';
import '../../../helpers/test_database.dart';

/// Where the app container was when the rows were written. On iOS it moves
/// across updates, so mapped paths must never come from here.
const _oldContainer = '/old-container';

void main() {
  late AppDatabase db;
  late ScannedDocumentsDao dao;
  late TempFileStorage storage;
  late ScannedDocumentRowMapper mapper;

  setUp(() async {
    db = createTestDatabase();
    dao = ScannedDocumentsDao(db);
    storage = await TempFileStorage.create();
    mapper = ScannedDocumentRowMapper(dao: dao, storage: storage);
  });
  tearDown(() async {
    await db.close();
    await storage.dispose();
  });

  /// Inserts a group and its pages; each page is (id, relative image path).
  Future<void> insertGroup(
    String id, {
    List<(String, String)> pages = const [],
  }) {
    final folder = p.join('scanned_documents', id);

    return dao.saveScanSession(
      group: ScannedDocumentsGroupsCompanion.insert(
        id: Value(id),
        name: 'Group $id',
        relativeFolderPath: folder,
        absoluteFolderPath: p.join(_oldContainer, folder),
      ),
      documents: [
        for (final (docId, relative) in pages)
          ScannedDocumentsCompanion.insert(
            id: Value(docId),
            groupId: id,
            name: 'Page $docId',
            relativeImagePath: relative,
            absoluteImagePath: p.join(_oldContainer, relative),
          ),
      ],
      onFileStorage: () async {},
    );
  }

  group('documents', () {
    test('resolves image paths against the current documents folder',
        () async {
      final relative = p.join('scanned_documents', 'g1', 'a.jpg');
      await insertGroup('g1', pages: [('d1', relative)]);

      final [doc] = await mapper.documents(await dao.getDocumentsForGroup('g1'));

      expect(doc.absoluteFilePath, storage.pathOf(relative));
      expect(doc.absoluteFilePath, isNot(startsWith(_oldContainer)));
      expect(doc.relativeFilePath, relative);
    });

    test('takes the extension from the file name, without the dot', () async {
      await insertGroup('g1', pages: [
        ('d1', p.join('scanned_documents', 'g1', 'a.jpg')),
        ('d2', p.join('scanned_documents', 'g1', 'b.png')),
        ('d3', p.join('scanned_documents', 'g1', 'c')),
      ]);

      final docs = await mapper.documents(await dao.getDocumentsForGroup('g1'));
      final extById = {for (final doc in docs) doc.id: doc.ext};

      expect(extById, {'d1': 'jpg', 'd2': 'png', 'd3': ''});
    });

    test('carries the row fields across', () async {
      await insertGroup('g1', pages: [
        ('d1', p.join('scanned_documents', 'g1', 'a.jpg')),
      ]);
      final [row] = await dao.getDocumentsForGroup('g1');

      final [doc] = await mapper.documents([row]);

      expect(doc.id, row.id);
      expect(doc.groupId, row.groupId);
      expect(doc.name, row.name);
      expect(doc.createdAt, row.createdAt);
      expect(doc.updatedAt, row.updatedAt);
    });
  });

  group('group', () {
    test('maps the row with its pages', () async {
      await insertGroup('g1', pages: [
        ('d1', p.join('scanned_documents', 'g1', 'a.jpg')),
        ('d2', p.join('scanned_documents', 'g1', 'b.jpg')),
      ]);
      final row = await dao.getGroup('g1');

      final group = await mapper.group(row);

      expect(group.id, 'g1');
      expect(group.groupName, 'Group g1');
      expect(group.relativeFolderPath, row.relativeFolderPath);
      expect(group.documents.map((doc) => doc.id), unorderedEquals(['d1', 'd2']));
    });

    test('a group without pages maps to no documents', () async {
      await insertGroup('g1');

      final group = await mapper.group(await dao.getGroup('g1'));

      expect(group.documents, isEmpty);
    });

    test('only its own pages', () async {
      await insertGroup('g1', pages: [
        ('d1', p.join('scanned_documents', 'g1', 'a.jpg')),
      ]);
      await insertGroup('g2', pages: [
        ('d2', p.join('scanned_documents', 'g2', 'b.jpg')),
      ]);

      final group = await mapper.group(await dao.getGroup('g1'));

      expect(group.documents.map((doc) => doc.id), ['d1']);
    });
  });

  test('groups keeps the order of the rows it is given', () async {
    await insertGroup('g1');
    await insertGroup('g2');
    final rows = [await dao.getGroup('g2'), await dao.getGroup('g1')];

    final groups = await mapper.groups(rows);

    expect(groups.map((group) => group.id), ['g2', 'g1']);
  });
}