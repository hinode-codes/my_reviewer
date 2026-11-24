import 'dart:async';

import 'package:my_reviewer/src/features/scanned_documents/models/ocr_job_payload.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_local_ocr_engine.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/strings.dart';
import 'package:my_reviewer/src/shared/models/job_cancelled_exception.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_handler.dart';
import 'package:my_reviewer/src/shared/services/jobs/job_execution_context.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';

class OcrTranscriptionJobHandler implements IJobHandler {
  const OcrTranscriptionJobHandler({
    required this._storageService,
    required this._ocrEngine,
    required this._transcriptionWriteRepo,
    this.checkpointEveryTokens = 10,
    this.wordsPerMinute = 200,
    this.warmUpTimeout = const Duration(seconds: 10),
  });

  final IFileStorageService _storageService;
  final ILocalOcrEngine _ocrEngine;
  final ITranscriptionWriteRepository _transcriptionWriteRepo;

  final int checkpointEveryTokens;
  final int wordsPerMinute;
  final Duration warmUpTimeout;

  @override
  Future<void> execute(JobModel job, JobExecutionContext context) async {
    final payload = OcrJobPayload.fromRawJson(job.payload);
    final absoluteImagePath = _storageService.resolveAbsolutePath(
      payload.relativePath,
    );

    // Ensure Qwen-VL + mmproj + LoRA are loaded before starting the page timer.
    await _ocrEngine.warmUp().timeout(
      warmUpTimeout,
      onTimeout: () => throw TimeoutException(
        'OCR model warm-up exceeded ${warmUpTimeout.inSeconds}s',
        warmUpTimeout,
      ),
    );

    // Refresh lease heartbeat and abort early if cancelled while loading model.
    if (!await context.checkpoint(elapsedMs: job.elapsedMs)) {
      throw JobCancelledException(job.id);
    }

    final prefill = preparePrefill(job.partialOutput);
    final buffer = StringBuffer(prefill);

    final stopwatch = Stopwatch()..start();
    final baseElapsedMs = job.elapsedMs;
    var chunksSinceCheckpoint = 0;

    try {
      final rawStream = _ocrEngine.transcribeImage(
        absoluteImagePath: absoluteImagePath,
        prefillText: prefill.isEmpty ? null : prefill,
      );

      final stream = guardOcrMarkdownStream(rawStream, initialText: prefill);

      await for (final chunk in stream) {
        buffer.write(chunk);
        chunksSinceCheckpoint++;

        if (chunksSinceCheckpoint >= checkpointEveryTokens) {
          chunksSinceCheckpoint = 0;

          final stillActive = await context.checkpoint(
            partialOutput: buffer.toString(),
            elapsedMs: baseElapsedMs + stopwatch.elapsedMilliseconds,
          );

          if (!stillActive) {
            throw JobCancelledException(job.id);
          }
        }
      }
    } on JobCancelledException {
      rethrow;
    } catch (_) {
      // Flush any tokens streamed since the last checkpoint so retries resume
      // from the furthest point reached rather than losing up to N-1 tokens.
      if (chunksSinceCheckpoint > 0) {
        await context.checkpoint(
          partialOutput: buffer.toString(),
          elapsedMs: baseElapsedMs + stopwatch.elapsedMilliseconds,
        );
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }

    final finalText = cleanOcrMarkdown(buffer.toString());
    if (finalText.trim().isEmpty) {
      throw StateError(
        'OCR inference completed with empty transcription output',
      );
    }

    final totalElapsedMs = baseElapsedMs + stopwatch.elapsedMilliseconds;

    final stillActive = await context.checkpoint(
      partialOutput: finalText,
      elapsedMs: totalElapsedMs,
    );

    if (!stillActive) {
      throw JobCancelledException(job.id);
    }

    final wordCount = countWords(finalText);
    final timeMsToRead = estimateReadTimeMs(
      wordCount,
      wordsPerMinute: wordsPerMinute,
    );

    await _transcriptionWriteRepo.saveTranscription(
      groupId: payload.groupId,
      docId: payload.docId,
      content: finalText,
      timeMsToTranscribe: totalElapsedMs,
      timeMsToRead: timeMsToRead,
      wordCount: wordCount,
      ext: payload.ext,
    );
  }

  @override
  void dispose() {
    // Lifecycle of _ocrEngine is owned by GetIt registration.
  }
}
