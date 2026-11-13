import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs/scan_preview_controller.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/models/docs/scan_view_models.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/repositories/scanned_document/interface.dart';
import 'package:my_reviewer/src/services/document_scanner_service.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';

class GroupEditController extends ChangeNotifier {
  final ScanPreviewController previewController;

  late final ProgressTask<void> saveTask;

  ScanSessionSnapshot _baseline;

  final IScannedDocumentRepository _repository;

  ScanSessionPhase _session = ScanSessionPhase.editing;

  ItemsStatus _status = ItemsStatus.loading;
  ItemsStatus get status => _status;

  bool get _matchesBaseline => previewController.snapshot == _baseline;

  final ScannedDocumentGroupModel? _initialGroup;
  final String _docId;

  GroupEditController({
    required this._repository,
    required IDocumentScannerService scanner,
    required FileStorageService storageService,
    required this._docId,
    this._initialGroup,
  }) : previewController = ScanPreviewController(
         scanner: scanner,
         storageService: storageService,
       ),
       _status = _initialGroup == null
           ? ItemsStatus.loading
           : ItemsStatus.ready,
       _baseline = _initialGroup == null
           ? ScanSessionSnapshot.empty
           : ScanSessionSnapshot.stored(_initialGroup) {
    saveTask = ProgressTask(_save);
    previewController.addListener(notifyListeners);
  }

  bool _disposed = false;

  Future<void> initialize() async {
    if (_initialGroup != null) {
      previewController.reset(_baseline);

      return;
    }

    try {
      final group = await _repository.getScannedDocumentGroup(_docId);

      if (_disposed) {
        return;
      }

      _baseline = ScanSessionSnapshot.stored(group);
      _status = ItemsStatus.ready;

      previewController.reset(_baseline);
    } catch (err) {
      debugPrint(err.toString());

      _baseline = ScanSessionSnapshot.empty;
      _status = ItemsStatus.failed;

      previewController.reset(_baseline);
    }

    notifyListeners();
  }

  // EditScanController: unsaved means the draft differs from what was loaded.
  // That includes an emptied group, whose save deletes it.
  SaveAvailability get saveAvailability => switch (_session) {
    ScanSessionPhase.saved => SaveAvailability.nothingToSave,
    ScanSessionPhase.editing =>
      _matchesBaseline
          ? SaveAvailability.nothingToSave
          : SaveAvailability.available,
  };

  ScanExitGuard get exitGuard => switch (_session) {
    ScanSessionPhase.saved => ScanExitGuard.allowed,
    ScanSessionPhase.editing =>
      _matchesBaseline ? ScanExitGuard.allowed : ScanExitGuard.confirmNeeded,
  };

  Future<void> _save(OperationProgressCallback onProgress) async {
    final snapshot = previewController.snapshot;

    if (snapshot.pages.isEmpty) {
      await _repository.deleteScannedDocumentGroups([
        snapshot.groupId,
      ], onProgress: onProgress);

      if (_disposed) {
        return;
      }

      _markSaved(snapshot);

      return;
    }

    await _repository.updateScannedDocumentGroup(
      groupId: snapshot.groupId,
      groupName: snapshot.groupName,
      existingDocuments: snapshot.docsWithPageType(ScanPageType.stored),
      newDocuments: snapshot.docsWithPageType(ScanPageType.ephemeral),
      onProgress: onProgress,
    );

    if (_disposed) {
      return;
    }
    
    // The screen leaves right after saving, so the draft is not reloaded:
    // a failed reload would fail a save that already succeeded, and Retry
    // would then save again from temp files that are gone. If the screen
    // ever stays, reload here and reset both the draft and the baseline.
    _markSaved(snapshot);
  }

  /// Set before `committed`, so its single notify already carries the
  /// finished state; nothing can observe "saved but still dirty".
  void _markSaved(ScanSessionSnapshot snapshot) {
    _session = ScanSessionPhase.saved;
    previewController.committed(snapshot);
  }

  @override
  void dispose() {
    _disposed = true;
    previewController.dispose();
    saveTask.dispose();
    super.dispose();
  }
}
