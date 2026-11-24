import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_model_provisioner.dart';
import 'package:my_reviewer/src/shared/services/app_settings_service.dart';

/// Coordinates selection, inspection, provisioning, and cleanup of on-device
/// AI models.
///
/// Tracks two model pointers:
/// - [activeModelId]: The last model successfully provisioned and persisted in
///   [AppSettingsService].
/// - [selectedModelId]: The model currently focused in the UI, which may be in
///   an unready or recoverable state prior to provisioning.
class AiModelSelectorController extends ChangeNotifier {
  /// Creates a selector controller for the given non-empty [models] catalog.
  AiModelSelectorController({
    required this.models,
    required this._provisioner,
    required this._settingsService,
  }) : assert(models.isNotEmpty) {
    provisionTask = TaskController<void>(_runProvision);
  }

  /// Catalog of available AI models that the user can choose from.
  final List<AiModelSpec> models;
  final AiModelProvisioner _provisioner;
  final AppSettingsService _settingsService;

  /// Background task controller driving model download, verification, and
  /// runtime integration with progress reporting.
  late final TaskController<void> provisionTask;

  final Map<String, AiModelStatus> _statusesById = {};
  final Map<String, String> _errorsById = {};

  late String _activeModelId = models.first.id;
  late String _targetModelId = models.first.id;
  ProvisionPhase _provisionPhase = ProvisionPhase.downloading;
  bool _initialized = false;
  bool _disposed = false;

  /// ID of the currently active, ready-to-use model.
  String get activeModelId => _activeModelId;

  /// ID of the model currently selected in the UI (may require setup or
  /// recovery before becoming [activeModelId]).
  String get selectedModelId => _targetModelId;

  /// Current pipeline stage of an active [provisionTask] execution.
  ProvisionPhase get provisionPhase => _provisionPhase;

  /// Specification for [selectedModelId], falling back to [models.first] if
  /// not found.
  AiModelSpec get selectedModel => models.firstWhere(
    (m) => m.id == _targetModelId,
    orElse: () => models.first,
  );

  /// Latest inspected installation status for [selectedModel].
  AiModelStatus get selectedStatus =>
      _statusesById[_targetModelId] ??
      AiModelStatus(
        spec: selectedModel,
        phase: AiModelInstallPhase.notInstalled,
      );

  /// Returns the cached [AiModelStatus] for [spec], defaulting to
  /// [AiModelInstallPhase.notInstalled] before [initialize] completes.
  AiModelStatus statusFor(AiModelSpec spec) =>
      _statusesById[spec.id] ??
      AiModelStatus(spec: spec, phase: AiModelInstallPhase.notInstalled);

  /// Restores the persisted active model ID from [AppSettingsService] and
  /// inspects on-disk statuses for all registered [models].
  Future<void> initialize() async {
    final savedId = await _settingsService.getSelectedOcrModelId();

    if (savedId != null && models.any((m) => m.id == savedId)) {
      _activeModelId = savedId;
      _targetModelId = savedId;
    }

    await refreshStatuses();

    if (!_disposed) {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Re-inspects on-disk artifacts for every model in [models] and updates
  /// cached statuses.
  Future<void> refreshStatuses() async {
    for (final spec in models) {
      _statusesById[spec.id] = await _provisioner.inspect(
        spec,
        lastError: _errorsById[spec.id],
      );
    }

    if (!_disposed && _initialized) {
      notifyListeners();
    }
  }

  /// Focuses [modelId] and switches immediately if its files are already ready.
  ///
  /// - Returns `true` when [modelId] is [AiModelInstallPhase.ready], re-running
  ///   lightweight runtime integration and persisting the selection.
  /// - Returns `false` if [modelId] is unknown or requires downloading,
  ///   verification, or recovery, signaling the caller to prompt the user.
  Future<bool> selectModel(String modelId) async {
    if (!models.any((m) => m.id == modelId)) {
      return false;
    }

    _targetModelId = modelId;
    final status = await _provisioner.inspect(
      selectedModel,
      lastError: _errorsById[modelId],
    );
    _statusesById[modelId] = status;

    if (status.phase == AiModelInstallPhase.ready) {
      await _provisioner.provision(selectedModel);

      _activeModelId = modelId;

      await _settingsService.setSelectedOcrModelId(modelId);

      if (!_disposed) {
        notifyListeners();
      }

      return true;
    }

    if (!_disposed) {
      notifyListeners();
    }

    return false;
  }

  /// Deletes partial or corrupted files for [selectedModel], clears its last
  /// error, and reverts [selectedModelId] back to [activeModelId].
  Future<void> discardIncomplete() async {
    final spec = selectedModel;

    await _provisioner.deleteModelFiles(spec);

    _errorsById.remove(spec.id);

    _statusesById[spec.id] = await _provisioner.inspect(spec);
    _targetModelId = _activeModelId;

    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Provisions [selectedModel] across download, verification, and integration
  /// stages, persisting [activeModelId] upon success.
  Future<void> _runProvision(MyReviewerTaskProgressCallback onProgress) async {
    final spec = selectedModel;

    _errorsById.remove(spec.id);

    try {
      final token = spec.requiresAuthToken
          ? await _settingsService.getHuggingFaceToken()
          : null;
      final wifiOnly = await _settingsService.isWifiOnlyDownloads();

      await _provisioner.provision(
        spec,
        authToken: token,
        requiresWiFi: wifiOnly,
        onPhaseChanged: (phase) {
          _provisionPhase = phase;
          if (!_disposed) {
            notifyListeners();
          }
        },
        onProgress: onProgress,
      );

      _activeModelId = spec.id;

      await _settingsService.setSelectedOcrModelId(spec.id);
    } catch (err) {
      _errorsById[spec.id] = err.toString();
      rethrow;
    } finally {
      _statusesById[spec.id] = await _provisioner.inspect(
        spec,
        lastError: _errorsById[spec.id],
      );

      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;

    provisionTask.dispose();
    super.dispose();
  }
}
