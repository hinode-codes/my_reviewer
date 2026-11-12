import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/controllers/docs/scan_preview_controller.dart';
import 'package:my_reviewer/src/models/docs/scan_view_models.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/utils/string.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/fake_document_scanner.dart';
import '../../../helpers/notification_counter.dart';
import '../../../helpers/temp_file_storage.dart';

void main() {
  late TempFileStorage storage;
  late FakeDocumentScanner scanner;
  late ScanPreviewController controller;
  late NotificationCounter notifications;
  var disposed = false;

  setUp(() async {
    storage = await TempFileStorage.create();
    scanner = FakeDocumentScanner();
    controller = ScanPreviewController(
      scanner: scanner,
      storageService: storage,
    );
    notifications = NotificationCounter(controller);
    disposed = false;
  });
  tearDown(() async {
    // A test that disposed the controller itself already removed the
    // counter; doing either twice would hit a disposed ChangeNotifier.
    if (!disposed) {
      notifications.dispose();
      controller.dispose();
    }
    await storage.dispose();
  });

  void disposeController() {
    notifications.dispose();
    controller.dispose();
    disposed = true;
  }

  /// A scanner temp file on disk.
  Future<String> tempScan(String name) =>
      storage.write(p.join('cache', name), 'image');

  /// Scans [count] fresh temp files and returns their paths.
  Future<List<String>> scanPages(int count, {int from = 1}) async {
    final paths = [
      for (var i = from; i < from + count; i++) await tempScan('scan_$i.jpg'),
    ];
    scanner.returns(paths);
    expect(await controller.scan(), ScanOutcome.captured);
    return paths;
  }

  /// A group as it comes from the database, its images already saved.
  Future<ScanSessionSnapshot> storedGroup(int pageCount) async {
    final when = DateTime(2026);
    final docs = [
      for (var i = 0; i < pageCount; i++)
        ScannedDocumentModel(
          id: 'd$i',
          groupId: 'g1',
          name: 'Page $i',
          relativeFilePath: p.join('scanned_documents', 'Biology', 'p$i.jpg'),
          absoluteFilePath: await storage.write(
            p.join('scanned_documents', 'Biology', 'p$i.jpg'),
            'saved',
          ),
          createdAt: when,
          ext: 'jpg',
        ),
    ];

    return ScanSessionSnapshot(
      groupId: 'g1',
      groupName: 'Biology',
      pages: [
        for (final doc in docs)
          ScanPage(doc: doc, pageType: ScanPageType.stored),
      ],
    );
  }

  group('initially', () {
    test('is idle with an empty session', () {
      expect(controller.scannerStatus, ScannerStatus.idle);
      expect(controller.snapshot, ScanSessionSnapshot.empty);
      expect(controller.pageCount, 0);
      expect(controller.currentDoc, isNull);
      expect(controller.docs, isEmpty);
      expect(controller.imagePaths, isEmpty);
    });
  });

  group('scan', () {
    test('captured pages become new, unsaved pages of a new group', () async {
      final paths = await scanPages(2);

      expect(controller.groupID, isNotEmpty);
      expect(controller.groupName, isNotEmpty);
      expect(controller.pageCount, 2);
      expect(controller.imagePaths, paths);
      for (final page in controller.snapshot.pages) {
        expect(page.pageType, ScanPageType.ephemeral);
        expect(page.doc.groupId, controller.groupID);
        expect(page.doc.ext, 'jpg');
      }
    });

    test('pages are named after the group, numbered in order', () async {
      await scanPages(2);

      expect(controller.docs.map((doc) => doc.name), [
        ScannedDocumentModel.fallbackFileName(controller.groupName, 0),
        ScannedDocumentModel.fallbackFileName(controller.groupName, 1),
      ]);
    });

    test('a second scan adds to the same group and keeps numbering', () async {
      await scanPages(2);
      final groupId = controller.groupID;
      final groupName = controller.groupName;

      await scanPages(1, from: 3);

      expect(controller.groupID, groupId);
      expect(controller.groupName, groupName);
      expect(controller.pageCount, 3);
      expect(
        controller.docs.last.name,
        ScannedDocumentModel.fallbackFileName(groupName, 2),
      );
    });

    test('every page gets its own id', () async {
      await scanPages(3);

      expect(controller.docs.map((doc) => doc.id).toSet(), hasLength(3));
    });

    test('is scanning while the scanner is open, idle after', () async {
      final open = scanner.holds();

      final scanning = controller.scan();
      expect(controller.scannerStatus, ScannerStatus.scanning);

      open.complete([await tempScan('scan_1.jpg')]);
      await scanning;
      expect(controller.scannerStatus, ScannerStatus.idle);
    });

    test('a scan while one is open is skipped', () async {
      final open = scanner.holds();
      final first = controller.scan();

      expect(await controller.scan(), ScanOutcome.skipped);
      expect(scanner.calls, 1);

      open.complete(null);
      await first;
    });

    test('leaving the scanner without pages is a cancel', () async {
      scanner.cancels();

      expect(await controller.scan(), ScanOutcome.cancelled);
      expect(controller.pageCount, 0);
      expect(controller.scannerStatus, ScannerStatus.idle);
    });

    test('an empty result is a cancel too', () async {
      scanner.returns(const []);

      expect(await controller.scan(), ScanOutcome.cancelled);
      expect(controller.pageCount, 0);
    });

    test('a scanner error is a failure and leaves it idle', () async {
      scanner.throws(StateError('camera unavailable'));

      expect(await controller.scan(), ScanOutcome.failed);
      expect(controller.pageCount, 0);
      expect(controller.scannerStatus, ScannerStatus.idle);
    });
  });

  group('editing', () {
    setUp(() async {
      await scanPages(3);
      notifications.reset();
    });

    test('renaming the group', () {
      controller.updateGroupName('Biology');

      expect(controller.groupName, 'Biology');
      expect(controller.groupNameValidation, validateName('Biology'));
      expect(notifications.count, 1);
    });

    test('renaming the group to its current name does nothing', () {
      controller.updateGroupName(controller.groupName);

      expect(notifications.count, 0);
    });

    test('renaming a page', () {
      controller.updateDocName(1, 'Cells');

      expect(controller.docs[1].name, 'Cells');
      expect(controller.docs[0].name, isNot('Cells'));
      expect(notifications.count, 1);
    });

    test('renaming a page out of range does nothing', () {
      final before = controller.snapshot;

      controller
        ..updateDocName(-1, 'x')
        ..updateDocName(3, 'x');

      expect(controller.snapshot, same(before));
      expect(notifications.count, 0);
    });

    test('removing a page keeps the others in order', () {
      final [first, _, third] = controller.docs;

      controller.removeDocAt(1);

      expect(controller.docs.map((doc) => doc.id), [first.id, third.id]);
      expect(controller.imagePaths, [
        first.absoluteFilePath,
        third.absoluteFilePath,
      ]);
    });

    test('removing out of range does nothing', () {
      controller.removeDocAt(5);

      expect(controller.pageCount, 3);
      expect(notifications.count, 0);
    });

    test('removing the last page empties the session', () {
      controller
        ..removeDocAt(0)
        ..removeDocAt(0)
        ..removeDocAt(0);

      expect(controller.pageCount, 0);
      expect(controller.currentDoc, isNull);
    });

    test('docs and image paths cannot be modified from outside', () {
      expect(() => controller.docs.removeLast(), throwsUnsupportedError);
      expect(() => controller.imagePaths.clear(), throwsUnsupportedError);
    });
  });

  group('current page', () {
    setUp(() => scanPages(3));

    test('can be moved to any valid index', () {
      controller.setCurrentIndex(2);

      expect(controller.currentIndex, 2);
      expect(controller.currentDoc, controller.docs[2]);
    });

    test('ignores invalid indexes and the index it is already on', () {
      notifications.reset();

      controller
        ..setCurrentIndex(-1)
        ..setCurrentIndex(3)
        ..setCurrentIndex(0);

      expect(controller.currentIndex, 0);
      expect(notifications.count, 0);
    });

    test('moves back when the page it was on is removed from the end', () {
      controller
        ..setCurrentIndex(2)
        ..removeDocAt(2);

      expect(controller.currentIndex, 1);
    });

    test('stays put when a page before it is removed', () {
      controller
        ..setCurrentIndex(1)
        ..removeDocAt(0);

      expect(controller.currentIndex, 1);
    });

    test('goes back to 0 when the session empties', () {
      controller
        ..setCurrentIndex(2)
        ..reset(ScanSessionSnapshot.empty);

      expect(controller.currentIndex, 0);
    });
  });

  group('reset', () {
    test('loads a stored group as stored pages', () async {
      final stored = await storedGroup(2);

      controller.reset(stored);

      expect(controller.snapshot, stored);
      expect(controller.groupID, 'g1');
      expect(controller.docs.map((doc) => doc.id), ['d0', 'd1']);
    });

    test('a scan after loading adds new pages to that group', () async {
      controller.reset(await storedGroup(2));

      await scanPages(1);

      expect(controller.groupID, 'g1');
      expect(
        controller.snapshot.docsWithPageType(ScanPageType.ephemeral),
        hasLength(1),
      );
    });
  });

  group('temp files', () {
    test('committing releases every captured file, removed pages included',
        () async {
      final paths = await scanPages(3);
      controller.removeDocAt(0);

      controller.committed(ScanSessionSnapshot.empty);

      for (final path in paths) {
        expect(File(path).existsSync(), isFalse, reason: path);
      }
    });

    test('committing loads the snapshot it is given', () async {
      await scanPages(1);
      final stored = await storedGroup(1);

      controller.committed(stored);

      expect(controller.snapshot, stored);
    });

    test('disposing releases captured files', () async {
      final paths = await scanPages(2);

      disposeController();

      for (final path in paths) {
        expect(File(path).existsSync(), isFalse, reason: path);
      }
    });

    test('never deletes the saved images of a stored group', () async {
      final stored = await storedGroup(2);
      controller.reset(stored);
      await scanPages(1);

      controller.removeDocAt(0);
      disposeController();

      for (final page in stored.pages) {
        expect(
          File(page.doc.absoluteFilePath).existsSync(),
          isTrue,
          reason: page.doc.absoluteFilePath,
        );
      }
    });
  });

  test('removing every page of a stored group keeps the group identity',
      () async {
    controller.reset(await storedGroup(2));

    controller
      ..removeDocAt(0)
      ..removeDocAt(0);

    expect(controller.groupID, 'g1');
    expect(controller.groupName, 'Biology');
  });
}