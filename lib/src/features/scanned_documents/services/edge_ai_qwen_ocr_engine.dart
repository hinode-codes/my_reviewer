import 'dart:io';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_local_ocr_engine.dart';

class EdgeAiQwenOcrEngine implements ILocalOcrEngine {
  EdgeAiQwenOcrEngine({
    this.maxTokens = 4096,
    this.preferredBackend = PreferredBackend.gpu,
    this.systemPrompt =
        'You are an accurate OCR assistant. Transcribe all visible text from '
        'the image faithfully, preserving paragraph structure and line '
        'breaks. Output only the transcribed text without commentary.',
    this.userPrompt = 'Transcribe the text in this document image.',
  });

  final int maxTokens;
  final PreferredBackend preferredBackend;
  final String systemPrompt;
  final String userPrompt;

  InferenceModel? _model;
  Future<InferenceModel>? _loadingFuture;

  Future<InferenceModel> _getOrLoadModel() {
    final existing = _model;

    if (existing != null && !existing.isClosed) {
      return Future.value(existing);
    }

    return _loadingFuture ??= _loadModelInternal();
  }

  Future<InferenceModel> _loadModelInternal() async {
    try {
      // Restores the active GGUF model + paired LoRA adapter installed via Settings.
      // Throws NoActiveModelError (StateError) if no model is installed/ready.
      final model = await FlutterEdgeAi.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: preferredBackend,
        supportImage: true,
      );
      _model = model;

      return model;
    } finally {
      _loadingFuture = null;
    }
  }

  @override
  Stream<String> transcribeImage({
    required String absoluteImagePath,
    String? prefillText,
  }) async* {
    final imageFile = File(absoluteImagePath);

    if (!await imageFile.exists()) {
      throw FileSystemException(
        'Scanned image not found for OCR',
        absoluteImagePath,
      );
    }

    final model = await _getOrLoadModel();
    final session = await model.openSession();

    try {
      await session.addQueryChunk(
        Message.text(text: systemPrompt, isUser: true),
      );
      // Scope imageBytes so it is eligible for GC before token streaming starts.
      {
        final imageBytes = await imageFile.readAsBytes();

        await session.addQueryChunk(
          Message.withImage(
            text: userPrompt,
            imageBytes: imageBytes,
            isUser: true,
          ),
        );
      }

      // Seed prior streamed text as an assistant chunk when resuming from a
      // checkpoint so Qwen-VL continues without repeating earlier lines.
      if (prefillText != null && prefillText.isNotEmpty) {
        await session.addQueryChunk(
          Message.text(text: prefillText, isUser: false),
        );
      }

      await for (final chunk in session.getResponseAsync()) {
        if (chunk.isNotEmpty) {
          yield chunk;
        }
      }
    } finally {
      await session.close();
    }
  }

  @override
  Future<void> warmUp() async {
    await _getOrLoadModel();
  }

  @override
  Future<void> dispose() async {
    final model = _model;
    _model = null;

    if (model != null && !model.isClosed) {
      await model.close();
    }
  }
}
