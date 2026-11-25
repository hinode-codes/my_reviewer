import 'package:get_it/get_it.dart';
import 'package:my_reviewer/src/features/scanned_documents/jobs/ocr_transcription_job_handler.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_local_ocr_engine.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_handler.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';

import 'shared_locators.dart';

final getItBackground = GetIt.instance;

Future<void> setupBackgroundLocator() async {
  setupCoreLocators(getItBackground, isBackgroundIsolate: true);

  getItBackground.registerLazySingleton<IJobHandler>(
    () => OcrTranscriptionJobHandler(
      storageService: getItBackground<IFileStorageService>(),
      ocrEngine: getItBackground<ILocalOcrEngine>(),
      transcriptionWriteRepo: getItBackground<ITranscriptionWriteRepository>(),
    ),
  );

  // Wait for IFileStorageService (registered in setupCoreLocators) to finish initializing
  await getItBackground.allReady();
}
