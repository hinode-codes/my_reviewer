import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_scan_constants.dart';
import 'package:my_reviewer/src/models/docs/scan_view_models.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/services/document_scanner_service.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';
import 'package:my_reviewer/src/utils/string.dart';
import 'package:path/path.dart' as p;

class ScanPreviewController extends ChangeNotifier {
  final IDocumentScannerService _scanner;
  final FileStorageService _storageService;

  ScanPreviewController({
    required this._scanner,
    required this._storageService,
  });

  // All scanner temp files for this preview session.
  final Set<String> _capturedTmpPaths = {};

  ScanSessionSnapshot _snapshot = ScanSessionSnapshot.empty;
  ScanSessionSnapshot get snapshot => _snapshot;

  ScannerStatus _scannerStatus = ScannerStatus.idle;
  ScannerStatus get scannerStatus => _scannerStatus;

  List<ScannedDocumentModel> _docs = const [];
  List<ScannedDocumentModel> get docs => _docs;

  List<String> _imgPaths = const [];
  List<String> get imagePaths => _imgPaths;

  int get pageCount => _snapshot.pages.length;
  String get groupName => _snapshot.groupName;
  String get groupID => _snapshot.groupId;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  ScannedDocumentModel? get currentDoc =>
      _isValidIndex(_currentIndex) ? _snapshot.pages[_currentIndex].doc : null;

  NameValidation get groupNameValidation => validateName(groupName);

  NameValidation get currentDocNameValidation =>
      validateName(currentDoc?.name ?? '');

  void reset(ScanSessionSnapshot next) => _replace(next);

  void updateGroupName(String newName) {
    if (newName == groupName) {
      return;
    }

    _apply(_snapshot.copyWith(groupName: newName));
  }

  void setCurrentIndex(int index) {
    if (!_isValidIndex(index) || index == _currentIndex) {
      return;
    }

    _currentIndex = index;

    notifyListeners();
  }

  void updateDocName(int index, String newName) {
    if (!_isValidIndex(index)) {
      return;
    }

    final pages = [..._snapshot.pages];
    pages[index] = pages[index].withName(newName);

    _apply(_snapshot.copyWith(pages: pages));
  }

  void removeDocAt(int index) {
    if (!_isValidIndex(index)) {
      return;
    }

    _apply(_snapshot.copyWith(pages: [..._snapshot.pages]..removeAt(index)));
  }

  Future<ScanOutcome> scan() async {
    switch (_scannerStatus) {
      case ScannerStatus.scanning:
        return ScanOutcome.skipped;
      case ScannerStatus.idle:
        break;
    }

    _scannerStatus = ScannerStatus.scanning;

    notifyListeners();

    try {
      final results = await _scanner.scanDocument();

      if (results == null || results.isEmpty) {
        return ScanOutcome.cancelled;
      }

      _appendPages(results);

      return ScanOutcome.captured;
    } catch (err) {
      debugPrint('Error scanning documents: $err');

      return ScanOutcome.failed;
    } finally {
      _scannerStatus = ScannerStatus.idle;

      notifyListeners();
    }
  }

  /// Call after a successful save. Clears the history, which also makes the
  /// temp files of pages removed before the save unreachable, so they are
  /// released now; the saved pages' temp files are already gone.
  void committed(ScanSessionSnapshot next) {
    _releaseTempFiles();
    reset(next);
  }

  void _apply(ScanSessionSnapshot next) => _replace(next);

  void _replace(ScanSessionSnapshot next) {
    _snapshot = next;

    final pageCount = next.pages.length;

    if (pageCount == 0) {
      _currentIndex = 0;
    } else if (_currentIndex >= pageCount) {
      _currentIndex = pageCount - 1;
    }

    _docs = List.unmodifiable(next.pages.map((page) => page.doc));
    _imgPaths = List.unmodifiable(
      next.pages.map((page) => page.doc.absoluteFilePath),
    );

    notifyListeners();
  }

  ScanSessionSnapshot _ensureGroup(DateTime createdAt) {
    if (_snapshot.groupId.isNotEmpty) {
      return _snapshot;
    }

    return _snapshot.copyWith(
      groupId: generateId(),
      groupName:
          '${DocsScanConstants.defaultGroupNamePrefix}'
          '${createdAt.millisecondsSinceEpoch}',
    );
  }

  void _appendPages(List<String> imgPaths) {
    final now = DateTime.now();
    final group = _ensureGroup(now);

    _capturedTmpPaths.addAll(imgPaths);

    final firstPageNumber = group.pages.length;

    _apply(
      group.copyWith(
        pages: [
          ...group.pages,
          for (int idx = 0; idx < imgPaths.length; ++idx)
            ScanPage(
              doc: ScannedDocumentModel(
                id: generateId(),
                groupId: group.groupId,
                name: ScannedDocumentModel.fallbackFileName(
                  group.groupName,
                  firstPageNumber + idx,
                ),
                relativeFilePath: "",
                absoluteFilePath: imgPaths[idx],
                createdAt: now,
                ext: p.extension(imgPaths[idx]).replaceFirst(".", ""),
              ),
              pageType: ScanPageType.ephemeral,
            ),
        ],
      ),
    );
  }

  void _releaseTempFiles() {
    _storageService.deleteQuietlyBatch(List.of(_capturedTmpPaths));
    _capturedTmpPaths.clear();
  }

  bool _isValidIndex(int index) => index >= 0 && index < _snapshot.pages.length;

  @override
  void dispose() {
    // Every unsaved exit ends here, so no temp file is left behind. A
    // remount after the ML Kit scanner returns would land here too, but it
    // starts the session from scratch, so these files would be orphaned
    // either way.
    _releaseTempFiles();
    super.dispose();
  }
}
