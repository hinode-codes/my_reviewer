import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_model_provisioner.dart';

typedef ModelIdReader = Future<String?> Function();
typedef ModelIdWriter = Future<void> Function(String modelId);
typedef AuthTokenReader = Future<String?> Function();
typedef WifiOnlyReader = Future<bool> Function();

class AiModelSelectorController extends ChangeNotifier {
  AiModelSelectorController({
    required this.models,
    required this._provisioner,
    required this._readSelectedModelId,
    required this._writeSelectedModelId,
    this._readAuthToken,
    this._readWifiOnly,
  }) : assert(models.isNotEmpty) {
    provisionTask = TaskController<void>(_runProvision);
  }

  final List<AiModelSpec> models;
  final AiModelProvisioner _provisioner;
  final ModelIdReader _readSelectedModelId;
  final ModelIdWriter _writeSelectedModelId;
  final AuthTokenReader? _readAuthToken;
  final WifiOnlyReader? _readWifiOnly;

  late final TaskController<void> provisionTask;

  final Map<String, AiModelStatus> _statusesById = {};
  final Map<String, String> _errorsById = {};

  late String _activeModelId = models.first.id;
  late String _targetModelId = models.first.id;
  ProvisionPhase _provisionPhase = ProvisionPhase.downloading;
  bool _initialized = false;
  bool _disposed = false;

  String get activeModelId => _activeModelId;
  String get selectedModelId => _targetModelId;
  ProvisionPhase get provisionPhase => _provisionPhase;

  AiModelSpec get selectedModel => models.firstWhere(
    (m) => m.id == _targetModelId,
    orElse: () => models.first,
  );

  AiModelStatus get selectedStatus =>
      _statusesById[_targetModelId] ??
      AiModelStatus(
        spec: selectedModel,
        phase: AiModelInstallPhase.notInstalled,
      );

  AiModelStatus statusFor(AiModelSpec spec) =>
      _statusesById[spec.id] ??
      AiModelStatus(spec: spec, phase: AiModelInstallPhase.notInstalled);

  Future<void> initialize() async {
    final savedId = await _readSelectedModelId();

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

  /// Selects [modelId] in the dropdown.
  /// - If already `ready`: re-runs lightweight `integrate` (ensures EdgeAI active
  ///   model points to this spec), persists [modelId], and returns `true`.
  /// - Otherwise: updates dropdown focus so the recovery/download banner appears
  ///   below the tile, and returns `false` so the UI triggers `TaskDialog`.
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
      await _writeSelectedModelId(modelId);
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

  Future<void> _runProvision(MyReviewerTaskProgressCallback onProgress) async {
    final spec = selectedModel;

    _errorsById.remove(spec.id);

    try {
      final token = spec.requiresAuthToken
          ? await _readAuthToken?.call()
          : null;
      final wifiOnly = await _readWifiOnly?.call() ?? false;

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
      await _writeSelectedModelId(spec.id);
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
