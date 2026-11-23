import 'dart:io';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_local_ocr_engine.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/models/ocr_models.dart';
import 'package:my_reviewer/src/shared/services/ai_models/i_ai_model_integrator.dart';

class EdgeAiOcrModelIntegrator implements IAiModelIntegrator {
  const EdgeAiOcrModelIntegrator({required this._ocrEngine});

  final ILocalOcrEngine _ocrEngine;

  @override
  bool supports(AiModelSpec spec) =>
      spec.capability == AiModelCapability.ocrTranscription;

  @override
  Future<void> integrate(
    AiModelSpec spec,
    Map<AiModelFileRole, String> resolvedPathsByRole,
  ) async {
    final modelPath = resolvedPathsByRole[AiModelFileRole.model]!;
    final adapterPath = resolvedPathsByRole[AiModelFileRole.adapter];

    // Release any previously loaded InferenceModel before swapping active model.
    await _ocrEngine.dispose();

    // Register the GGUF base model + optional LoRA adapter as the active model
    // in flutter_edge_ai. Core persists the active GGUF + paired LoRA across
    // restarts, and LlamaEngineProvider.projectorResolver supplies the mmproj.
    var builder = FlutterEdgeAi.installModel(
      modelType: _resolveModelType(spec.id),
      fileType: ModelFileType.gguf,
    ).fromFile(modelPath);

    if (adapterPath != null && await File(adapterPath).exists()) {
      builder = builder.withLoraFromFile(adapterPath);
    }

    await builder.install();
  }

  ModelType _resolveModelType(String specId) => switch (specId) {
    OcrModelCatalog.qwen3Vl2bId => ModelType.general,
    _ => ModelType.general,
  };

  @override
  Future<void> unintegrate(AiModelSpec spec) async {
    await _ocrEngine.dispose();
  }
}
