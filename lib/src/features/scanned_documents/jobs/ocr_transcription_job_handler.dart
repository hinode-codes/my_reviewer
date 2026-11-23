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
  });

  final IFileStorageService _storageService;
  final ILocalOcrEngine _ocrEngine;
  final ITranscriptionWriteRepository _transcriptionWriteRepo;

  final int checkpointEveryTokens;
  final int wordsPerMinute;

  @override
  Future<void> execute(JobModel job, JobExecutionContext context) async {
    final payload = OcrJobPayload.fromRawJson(job.payload);
    final absoluteImagePath = _storageService.resolveAbsolutePath(
      payload.relativePath,
    );

    // Ensure Qwen-VL + mmproj + LoRA are loaded before starting the page timer.
    await _ocrEngine.warmUp();

    final prefill = preparePrefill(job.partialOutput);
    final buffer = StringBuffer(prefill);

    final stopwatch = Stopwatch()..start();
    final baseElapsedMs = job.elapsedMs;
    var chunksSinceCheckpoint = 0;

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

    stopwatch.stop();

    final finalText = cleanOcrMarkdown(buffer.toString());
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
}
