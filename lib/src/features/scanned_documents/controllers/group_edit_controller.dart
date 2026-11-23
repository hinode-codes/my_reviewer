import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_preview_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scan_session_snapshot.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanner.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_document_scanner_service.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_groups_use_case.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/update_scanned_group_use_case.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';

class GroupEditController extends ChangeNotifier {
  GroupEditController({
    required this._readRepository,
    required this._updateGroupUseCase,
    required this._deleteGroupsUseCase,
    required IDocumentScannerService scanner,
    required IFileStorageService storageService,
    required this._groupId,
    ScannedDocumentGroupModel? initialGroup,
  }) : _initialGroup = initialGroup,
       previewController = ScanPreviewController(
         scanner: scanner,
         storageService: storageService,
       ),
       _status = initialGroup == null ? ItemsStatus.loading : ItemsStatus.ready,
       _baseline = initialGroup == null
           ? ScanSessionSnapshot.empty
           : ScanSessionSnapshot.stored(initialGroup) {
    previewController.addListener(_onPreviewChanged);
    saveTask = TaskController<void>(_save);
  }

  final IScannedDocumentReadRepository _readRepository;
  final UpdateScannedGroupUseCase _updateGroupUseCase;
  final DeleteScannedGroupsUseCase _deleteGroupsUseCase;
  final String _groupId;
  final ScannedDocumentGroupModel? _initialGroup;

  final ScanPreviewController previewController;
  late final TaskController<void> saveTask;

  ScanSessionSnapshot _baseline;

  ScanSessionPhase _session = ScanSessionPhase.editing;
  ScanSessionPhase get session => _session;

  ItemsStatus _status;
  ItemsStatus get status => _status;

  bool _disposed = false;

  bool get _matchesBaseline => previewController.snapshot == _baseline;

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

  Future<void> initialize() async {
    if (_initialGroup != null) {
      previewController.reset(_baseline);
      return;
    }

    try {
      final group = await _readRepository.getScannedDocumentGroup(_groupId);

      if (_disposed) {
        return;
      }

      _baseline = ScanSessionSnapshot.stored(group);
      _status = ItemsStatus.ready;
      previewController.reset(_baseline);
    } catch (err) {
      debugPrint(err.toString());

      if (_disposed) {
        return;
      }

      _baseline = ScanSessionSnapshot.empty;
      _status = ItemsStatus.failed;
      previewController.reset(_baseline);
    }

    notifyListeners();
  }

  void _onPreviewChanged() {
    if (_session == ScanSessionPhase.saved && !_matchesBaseline) {
      _session = ScanSessionPhase.editing;
    }

    notifyListeners();
  }

  Future<void> _save(MyReviewerTaskProgressCallback onProgress) async {
    final snapshot = previewController.snapshot;

    if (snapshot.pages.isEmpty) {
      await _deleteGroupsUseCase([snapshot.groupId], onProgress: onProgress);

      if (_disposed) {
        return;
      }

      _markSaved(snapshot);
      return;
    }

    await _updateGroupUseCase((
      groupId: snapshot.groupId,
      groupName: snapshot.groupName,
      existingDocuments: snapshot.storedDocuments,
      newPages: snapshot.pendingPages,
    ), onProgress: onProgress);

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
    previewController
      ..removeListener(_onPreviewChanged)
      ..dispose();
    saveTask.dispose();
    super.dispose();
  }
}
