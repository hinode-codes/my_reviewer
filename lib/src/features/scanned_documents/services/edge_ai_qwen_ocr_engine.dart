import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:image/image.dart' as img;
import 'package:my_reviewer/src/features/scanned_documents/services/i_local_ocr_engine.dart';

class EdgeAiQwenOcrEngine implements ILocalOcrEngine {
  EdgeAiQwenOcrEngine({
    this.maxTokens = 2048,
    this.maxImageDimension = 1024,
    this.jpegQuality = 85,
    this.firstTokenTimeout = const Duration(seconds: 10),
    this.userPrompt = 'Transcribe this handwritten page to Markdown.',
  });

  final int maxTokens;
  final int maxImageDimension;
  final int jpegQuality;
  final Duration firstTokenTimeout;
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
      final model = await FlutterEdgeAi.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: PreferredBackend.cpu,
        supportImage: true,
      );
      _model = model;
      return model;
    } finally {
      _loadingFuture = null;
    }
  }

  String _buildPrompt(String? prefillText) {
    if (prefillText == null || prefillText.isEmpty) {
      return userPrompt;
    }

    return '$userPrompt\n\n'
        'Continue transcribing immediately after the following already-transcribed text without repeating it:\n'
        '$prefillText';
  }

  /// Downscales oversized camera scans using pure-Dart `package:image` in a
  /// short-lived worker isolate so dynamic vision tokenization stays fast
  /// and well within [maxTokens] without blocking the background isolate.
  Future<Uint8List> _prepareImageBytes(File imageFile) async {
    final rawBytes = await imageFile.readAsBytes();
    final maxDim = maxImageDimension;
    final quality = jpegQuality;

    return Isolate.run(() {
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        return rawBytes;
      }

      final longestSide = decoded.width > decoded.height
          ? decoded.width
          : decoded.height;

      if (longestSide <= maxDim) {
        return rawBytes;
      }

      final resized = decoded.width >= decoded.height
          ? img.copyResize(
              decoded,
              width: maxDim,
              interpolation: img.Interpolation.linear,
            )
          : img.copyResize(
              decoded,
              height: maxDim,
              interpolation: img.Interpolation.linear,
            );

      return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    });
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

    final sw = Stopwatch()..start();
    final model = await _getOrLoadModel();
    debugPrint('[OCR] CPU model ready in ${sw.elapsedMilliseconds}ms');

    final session = await model.openSession();
    var timedOut = false;

    try {
      {
        final imageBytes = await _prepareImageBytes(imageFile);
        debugPrint(
          '[OCR] Image prepared (${imageBytes.length ~/ 1024} KB) at ${sw.elapsedMilliseconds}ms',
        );

        await session.addQueryChunk(
          Message.withImage(
            text: _buildPrompt(prefillText),
            imageBytes: imageBytes,
            isUser: true,
          ),
        );
      }

      var receivedFirstChunk = false;
      final stream = session.getResponseAsync().timeout(
        firstTokenTimeout,
        onTimeout: (sink) {
          if (!receivedFirstChunk) {
            sink.addError(
              TimeoutException(
                'OCR engine produced no tokens within ${firstTokenTimeout.inSeconds}s on CPU',
                firstTokenTimeout,
              ),
            );
          }
        },
      );

      await for (final chunk in stream) {
        if (chunk.isNotEmpty) {
          if (!receivedFirstChunk) {
            receivedFirstChunk = true;
            debugPrint('[OCR] First token at ${sw.elapsedMilliseconds}ms');
          }
          yield chunk;
        }
      }

      debugPrint('[OCR] Completed in ${sw.elapsedMilliseconds}ms');
    } on TimeoutException {
      timedOut = true;
      rethrow;
    } finally {
      if (timedOut) {
        unawaited(
          session.close().timeout(const Duration(seconds: 2), onTimeout: () {}),
        );
      } else {
        await session.close();
      }
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
