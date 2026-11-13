import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs/scan_preview_controller.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/models/docs/scan_view_models.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:my_reviewer/src/repositories/scanned_document/interface.dart';
import 'package:my_reviewer/src/services/document_scanner_service.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';

class DocsScanController extends ChangeNotifier {
  final ScanPreviewController previewController;

  late final ProgressTask<void> saveTask;

  final IScannedDocumentRepository _repository;

  DocsScanController({
    required this._repository,
    required IDocumentScannerService scanner,
    required FileStorageService storageService,
  }) : previewController = ScanPreviewController(
         scanner: scanner,
         storageService: storageService,
       ) {
    saveTask = ProgressTask(_save);
    previewController.addListener(notifyListeners);
  }

  ScanSessionPhase _session = ScanSessionPhase.editing;

  // NewScanController: nothing is stored yet, so any page is unsaved work.
  SaveAvailability get saveAvailability => switch (_session) {
    ScanSessionPhase.saved => SaveAvailability.nothingToSave,
    ScanSessionPhase.editing =>
      previewController.pageCount == 0
          ? SaveAvailability.nothingToSave
          : SaveAvailability.available,
  };

  ScanExitGuard get exitGuard => switch (_session) {
    ScanSessionPhase.saved => ScanExitGuard.allowed,
    ScanSessionPhase.editing =>
      previewController.pageCount == 0
          ? ScanExitGuard.allowed
          : ScanExitGuard.confirmNeeded,
  };

  bool _dispose = false;

  Future<void> _save(OperationProgressCallback onProgress) async {
    final snapshot = previewController.snapshot;

    await _repository.saveScannedDocuments(
      groupID: snapshot.groupId,
      groupName: snapshot.groupName,
      documents: previewController.docs,
      onProgress: onProgress,
    );

    if (_dispose) {
      return;
    }

    // The screen leaves right after saving, so the draft keeps showing what
    // was saved rather than reloading it. If the screen ever stays, open the
    // edit flow for the new group instead.
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
    _dispose = true;
    previewController.dispose();
    saveTask.dispose();
    super.dispose();
  }
}
