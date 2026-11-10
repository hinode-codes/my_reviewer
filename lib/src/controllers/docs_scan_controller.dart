import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_scan_constants.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/models/docs_scan_state.dart';
import 'package:my_reviewer/src/models/save_progress.dart';
import 'package:my_reviewer/src/repositories/scanned_document_repository.dart';
import 'package:my_reviewer/src/services/document_scanner_service.dart'
    show IDocumentScannerService;
import 'package:my_reviewer/src/utils/string.dart';
import 'package:path/path.dart' as p;

class DocsScanController extends ChangeNotifier {
  DocsScanController(this._scannerService, this._repository);
  final IScannedDocumentRespository _repository;
  final IDocumentScannerService _scannerService;

  DocsScanStatus _status = DocsScanStatus.notStarted;
  DocsScanStatus get status => _status;

  final List<String> _tempImagePaths = [];
  List<String> get tempImagePaths => List.unmodifiableOf(_tempImagePaths);

  final List<ScannedDocumentModel> _scannedDocs = [];
  List<ScannedDocumentModel> get scannedDocs =>
      List.unmodifiableOf(_scannedDocs);

  int get pageCount => _scannedDocs.length;

  String _groupName = '';
  String get groupName => _groupName;

  String _groupID = '';
  String get groupID => _groupID;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  ScannedDocumentModel? get currentDoc =>
      _isValidIndex(_currentIndex) ? _scannedDocs[_currentIndex] : null;

  DocsScanView get view {
    if (_scannedDocs.isNotEmpty) {
      return DocsScanView.preview;
    }

    return switch (_status) {
      DocsScanStatus.notStarted ||
      DocsScanStatus.scanning => DocsScanView.loading,
      DocsScanStatus.idle => DocsScanView.empty,
    };
  }

  NameValidation get groupNameValidation => validateName(_groupName);

  NameValidation get currentDocNameValidation =>
      validateName(currentDoc?.name ?? '');

  SaveStatus _saveStatus = SaveStatus.idle;
  SaveStatus get saveStatus => _saveStatus;

  SaveProgress? _saveProgress;
  SaveProgress? get saveProgress => _saveProgress;

  DocsScanExitGuard get exitGuard => _scannedDocs.isEmpty
      ? DocsScanExitGuard.allowed
      : DocsScanExitGuard.confirmNeeded;

  Future<SaveOutcome> save() async {
    if (_saveStatus == SaveStatus.saving) {
      return SaveOutcome.skipped;
    }

    if (_scannedDocs.isEmpty) {
      return SaveOutcome.nothingToSave;
    }

    _saveStatus = SaveStatus.saving;
    _saveProgress = const SaveProgress(stage: SaveStage.preparing);

    notifyListeners();

    try {
      await _repository.saveScannedDocuments(
        groupID: _groupID,
        groupName: _groupName,
        documents: _scannedDocs,
        onProgress: (progress) {
          _saveProgress = progress;
          notifyListeners();
        },
      );
      _saveStatus = SaveStatus.saved;
      notifyListeners();
      return SaveOutcome.saved;
    } catch (err) {
      debugPrint('Error saving scanned documents: $err');
      _saveStatus = SaveStatus.failed;
      notifyListeners();
      return SaveOutcome.failed;
    }
  }

  void updateGroupName(String newName) {
    if (newName == _groupName) {
      return;
    }

    _groupName = newName;
    notifyListeners();
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

    _scannedDocs[index] = _scannedDocs[index].copyWith(name: newName);
    notifyListeners();
  }

  void removeDocAt(int index) {
    if (!_isValidIndex(index)) {
      return;
    }

    _scannedDocs.removeAt(index);
    _tempImagePaths.removeAt(index);

    if (_scannedDocs.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= _scannedDocs.length) {
      _currentIndex = _scannedDocs.length - 1;
    }

    notifyListeners();
  }

  /// Opens the ML Kit scanner once, when the screen mounts. Later calls
  /// return [DocsScanOutcome.skipped].
  Future<DocsScanOutcome> startInitialScan() async {
    if (_status != DocsScanStatus.notStarted) {
      return DocsScanOutcome.skipped;
    }

    return _performScan();
  }

  /// Opens the scanner again to append pages to the current group.
  Future<DocsScanOutcome> scanMorePages() => _performScan();

  Future<DocsScanOutcome> _performScan() async {
    if (_status == DocsScanStatus.scanning) {
      return DocsScanOutcome.skipped;
    }

    _status = DocsScanStatus.scanning;
    notifyListeners();

    try {
      final results = await _scannerService.scanDocument();

      if (results == null || results.isEmpty) {
        return DocsScanOutcome.cancelled;
      }

      _appendPages(results);

      return DocsScanOutcome.captured;
    } catch (_) {
      return DocsScanOutcome.failed;
    } finally {
      _status = DocsScanStatus.idle;
      notifyListeners();
    }
  }

  void _appendPages(List<String> imagePaths) {
    final now = DateTime.now();

    _ensureGroup(now);

    _tempImagePaths.addAll(imagePaths);
    _scannedDocs.addAll(
      List.generate(
        imagePaths.length,
        (index) => ScannedDocumentModel(
          id: generateId(),
          name: ScannedDocumentModel.fallbackFileName(_groupName, index),
          groupId: _groupID,
          relativeFilePath: '',
          absoluteFilePath: imagePaths[index],
          createdAt: now,
          ext: p.extension(imagePaths[index]).replaceFirst('.', ''),
        ),
      ),
    );
  }

  /// Creates the group the first time pages are actually captured.
  void _ensureGroup(DateTime createdAt) {
    if (_groupID.isNotEmpty) {
      return;
    }

    _groupID = generateId();
    _groupName =
        '${DocsScanConstants.defaultGroupNamePrefix}'
        '${createdAt.millisecondsSinceEpoch}';
  }

  bool _isValidIndex(int index) => index >= 0 && index < _scannedDocs.length;
}
