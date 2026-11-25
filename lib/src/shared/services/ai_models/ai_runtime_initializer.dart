import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_llama/flutter_edge_ai_llama.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_model_provisioner.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:path/path.dart' as p;

typedef ActiveModelIdReader = Future<String?> Function();

class AiRuntimeInitializer {
  const AiRuntimeInitializer({
    required this._storageService,
    required this._registeredModels,
    required this._readActiveModelId,
    required this._provisioner,
    this.isBackgroundIsolate = false,
  });

  final IFileStorageService _storageService;
  final List<AiModelSpec> _registeredModels;
  final ActiveModelIdReader _readActiveModelId;
  final AiModelProvisioner _provisioner;
  final bool isBackgroundIsolate;

  Future<void> initialize() async {
    if (!isBackgroundIsolate) {
      await FileDownloader().trackTasks();
      await FileDownloader().resumeFromBackground();
    }

    final llamaProvider = LlamaEngineProvider(
      projectorResolver: (spec, config) => _resolveProjectorPath(),
    );

    await FlutterEdgeAi.initialize(inferenceEngines: [llamaProvider]);

    // Ensure the active verified model is registered in this isolate's
    // FlutterEdgeAi runtime (critical for background isolates).
    final activeId = await _readActiveModelId();
    final activeSpec = _registeredModels
        .where((m) => m.id == activeId)
        .firstOrNull;
    if (activeSpec != null) {
      await _provisioner.reintegrateIfReady(activeSpec);
    }
  }

  Future<String?> _resolveProjectorPath() async {
    if (_registeredModels.isEmpty) {
      return null;
    }

    final activeId = await _readActiveModelId();
    final modelSpec = _registeredModels.firstWhere(
      (m) => m.id == activeId,
      orElse: () => _registeredModels.first,
    );

    final mmprojArtifact = modelSpec.artifacts
        .where((a) => a.role == AiModelFileRole.mmproj)
        .firstOrNull;

    if (mmprojArtifact == null) {
      return null;
    }

    final dirPath = _storageService.resolveAbsolutePath(
      p.joinAll(modelSpec.relativeSubDirectories),
      root: modelSpec.storageRoot,
    );
    final mmprojFile = File(p.join(dirPath, mmprojArtifact.fileName));

    return await mmprojFile.exists() ? mmprojFile.path : null;
  }
}
