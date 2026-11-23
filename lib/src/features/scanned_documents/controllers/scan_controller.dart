import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_preview_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scan_session_snapshot.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanner.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_document_scanner_service.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';

class ScanController extends ChangeNotifier {
  ScanController({
    required this.writeRepository,
    required IDocumentScannerService scanner,
    required IFileStorageService storageService,
  }) : previewController = ScanPreviewController(
         scanner: scanner,
         storageService: storageService,
       ) {
    previewController.addListener(_onPreviewChanged);
    saveTask = TaskController<void>(_save);
  }

  final IScannedDocumentWriteRepository writeRepository;
  final ScanPreviewController previewController;
  late final TaskController<void> saveTask;

  ScanSessionPhase _session = ScanSessionPhase.editing;
  ScanSessionPhase get session => _session;

  bool _disposed = false;

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

  void _onPreviewChanged() {
    // If the user scans/edits again after a save, mark the session dirty again.
    if (_session == ScanSessionPhase.saved &&
        previewController.pendingPages.isNotEmpty) {
      _session = ScanSessionPhase.editing;
    }

    notifyListeners();
  }

  Future<void> _save(MyReviewerTaskProgressCallback onProgress) async {
    final snapshot = previewController.snapshot;
    final pendingPages = previewController.pendingPages;

    if (pendingPages.isEmpty) {
      return;
    }

    await writeRepository.saveScannedDocuments(
      groupId: snapshot.groupId,
      groupName: snapshot.groupName,
      pages: pendingPages,
      onProgress: onProgress,
    );

    if (_disposed) {
      return;
    }

    _session = ScanSessionPhase.saved;
    previewController.committed(ScanSessionSnapshot.empty);
  }

  @override
  void dispose() {
    _disposed = true;
    previewController
      ..removeListener(_onPreviewChanged)
      ..dispose();
    saveTask.dispose();
    super.dispose();
  }
}
