import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/constants/scan_constants.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scan_session_snapshot.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanner.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_document_scanner_service.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';
import 'package:path/path.dart' as p;

class ScanPreviewController extends ChangeNotifier {
  ScanPreviewController({
    required this._scanner,
    required this._storageService,
  });

  final IDocumentScannerService _scanner;
  final IFileStorageService _storageService;

  final Set<String> _capturedTmpPaths = {};
  Set<String> get capturedTmpPaths => Set.unmodifiable(_capturedTmpPaths);

  bool _disposed = false;
  bool get disposed => _disposed;

  ScanSessionSnapshot _snapshot = ScanSessionSnapshot.empty;
  ScanSessionSnapshot get snapshot => _snapshot;

  ScannerStatus _scannerStatus = ScannerStatus.idle;
  ScannerStatus get scannerStatus => _scannerStatus;

  List<ScannedPage> get pages => _snapshot.pages;

  /// Existing persisted documents still present in the session (for updates).
  List<ScannedDocumentModel> get existingDocuments => [
    for (final page in _snapshot.pages)
      if (page is StoredScannedPage) page.doc,
  ];

  /// Newly scanned unsaved pages in page order (ready for save/update repo).
  List<PendingScanPage> get pendingPages => [
    for (final page in _snapshot.pages)
      if (page is EphemeralScannedPage) page.pending,
  ];

  List<String> _imgPaths = const [];
  List<String> get imagePaths => _imgPaths;

  int get pageCount => _snapshot.pages.length;
  String get groupName => _snapshot.groupName;
  String get groupID => _snapshot.groupId;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  ScannedPage? get currentPage =>
      _isValidIndex(_currentIndex) ? _snapshot.pages[_currentIndex] : null;

  NameValidation get groupNameValidation => validateName(groupName);

  NameValidation get currentDocNameValidation =>
      validateName(currentPage?.name ?? '');

  void reset(ScanSessionSnapshot next) => _replace(next);

  void updateGroupName(String newName) {
    if (newName == groupName) return;
    _apply(_snapshot.copyWith(groupName: newName));
  }

  void setCurrentIndex(int index) {
    if (!_isValidIndex(index) || index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  void updateDocName(int index, String newName) {
    if (!_isValidIndex(index)) return;
    final updated = [..._snapshot.pages];
    updated[index] = updated[index].withName(newName);
    _apply(_snapshot.copyWith(pages: updated));
  }

  void removeDocAt(int index) {
    if (!_isValidIndex(index)) return;
    _apply(_snapshot.copyWith(pages: [..._snapshot.pages]..removeAt(index)));
  }

  Future<ScanOutcome> scan() async {
    if (_scannerStatus == ScannerStatus.scanning) {
      return ScanOutcome.skipped;
    }

    _scannerStatus = ScannerStatus.scanning;
    notifyListeners();

    try {
      final results = await _scanner.scanDocument();

      if (results == null || results.isEmpty) {
        return ScanOutcome.cancelled;
      }

      if (!_disposed) {
        _appendPages(results);
      }

      return ScanOutcome.captured;
    } catch (err) {
      debugPrint('Error scanning documents: $err');
      return ScanOutcome.failed;
    } finally {
      _scannerStatus = ScannerStatus.idle;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  void committed(ScanSessionSnapshot next) {
    _releaseTempFiles();
    reset(next);
  }

  void _apply(ScanSessionSnapshot next) => _replace(next);

  void _replace(ScanSessionSnapshot next) {
    _snapshot = next;

    final count = next.pages.length;
    if (count == 0) {
      _currentIndex = 0;
    } else if (_currentIndex >= count) {
      _currentIndex = count - 1;
    }

    _imgPaths = List.unmodifiable([
      for (final page in next.pages)
        switch (page) {
          StoredScannedPage(:final doc) => _storageService.resolveAbsolutePath(
            doc.relativePath,
          ),
          EphemeralScannedPage(:final pending) => pending.sourceAbsolutePath,
        },
    ]);

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

  void _appendPages(List<String> scannedAbsolutePaths) {
    final now = DateTime.now();
    final group = _ensureGroup(now);

    _capturedTmpPaths.addAll(scannedAbsolutePaths);

    final firstPageNumber = group.pages.length;

    _apply(
      group.copyWith(
        pages: [
          ...group.pages,
          for (int idx = 0; idx < scannedAbsolutePaths.length; ++idx)
            EphemeralScannedPage(
              PendingScanPage(
                id: generateId(),
                name: ScannedDocumentModel.fallbackFileName(
                  group.groupName,
                  firstPageNumber + idx,
                ),
                sourceAbsolutePath: scannedAbsolutePaths[idx],
                ext: p
                    .extension(scannedAbsolutePaths[idx])
                    .replaceFirst('.', ''),
              ),
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
    _disposed = true;
    _releaseTempFiles();
    super.dispose();
  }
}
