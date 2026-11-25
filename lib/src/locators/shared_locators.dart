import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_groups_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_transcription_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/local_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/local_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/local_transcription_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/local_transcription_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/edge_ai_qwen_ocr_engine.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_local_ocr_engine.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:my_reviewer/src/shared/db/dao/jobs_dao.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/ocr_models.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/local_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/local_job_write_repository.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_model_provisioner.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_runtime_initializer.dart';
import 'package:my_reviewer/src/shared/services/ai_models/edge_ai_ocr_integrator.dart';
import 'package:my_reviewer/src/shared/services/ai_models/i_ai_model_integrator.dart';
import 'package:my_reviewer/src/shared/services/app_settings_service.dart';
import 'package:my_reviewer/src/shared/services/foreground_tasks/foreground_task_commander.dart';
import 'package:my_reviewer/src/shared/services/storage/disk_file_storage_service.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';

void setupCoreLocators(GetIt getIt, {bool isBackgroundIsolate = false}) {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  // --- Eager Async Singletons ---
  getIt.registerSingletonAsync<IFileStorageService>(
    () => DiskFileStorageService.create(),
  );

  getIt.registerSingletonAsync<AppSettingsService>(() async {
    final settings = AppSettingsService();
    await settings.initialize();
    return settings;
  });

  // --- Database & DAOs ---
  getIt.registerLazySingleton<AppDatabase>(
    () => AppDatabase(),
    dispose: (db) => db.close(),
  );
  getIt.registerLazySingleton<ScannedDocumentDao>(
    () => ScannedDocumentDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ScannedDocumentGroupsDao>(
    () => ScannedDocumentGroupsDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ScannedDocumentTranscriptionDao>(
    () => ScannedDocumentTranscriptionDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<JobDao>(() => JobDao(getIt<AppDatabase>()));

  // --- Foreground Tasks & Repositories ---
  getIt.registerLazySingleton<ForegroundTaskCommander>(
    () => ForegroundTaskCommander(),
  );

  getIt.registerLazySingleton<IJobReadRepository>(
    () => LocalJobReadRepository(dao: getIt<JobDao>()),
  );
  getIt.registerLazySingleton<IJobWriteRepository>(
    () =>
        LocalJobWriteRepository(db: getIt<AppDatabase>(), dao: getIt<JobDao>()),
  );

  getIt.registerLazySingleton<ITranscriptionReadRepository>(
    () => LocalTranscriptionReadRepository(
      dao: getIt<ScannedDocumentTranscriptionDao>(),
    ),
  );
  getIt.registerLazySingleton<ITranscriptionWriteRepository>(
    () => LocalTranscriptionWriteRepository(
      db: getIt<AppDatabase>(),
      dao: getIt<ScannedDocumentTranscriptionDao>(),
      storageService: getIt<IFileStorageService>(),
    ),
  );

  getIt.registerLazySingleton<IScannedDocumentReadRepository>(
    () => LocalScannedDocumentReadRepository(
      groupsDao: getIt<ScannedDocumentGroupsDao>(),
      docsDao: getIt<ScannedDocumentDao>(),
    ),
  );
  getIt.registerLazySingleton<IScannedDocumentWriteRepository>(
    () => LocalScannedDocumentWriteRepository(
      db: getIt<AppDatabase>(),
      groupsDao: getIt<ScannedDocumentGroupsDao>(),
      docsDao: getIt<ScannedDocumentDao>(),
      storageService: getIt<IFileStorageService>(),
    ),
  );

  // --- AI Runtime, Provisioner & Engine ---
  getIt.registerLazySingleton<ILocalOcrEngine>(
    () => EdgeAiQwenOcrEngine(),
    dispose: (engine) => engine.dispose(),
  );

  getIt.registerLazySingleton<IAiModelIntegrator>(
    () => EdgeAiOcrModelIntegrator(ocrEngine: getIt<ILocalOcrEngine>()),
  );

  getIt.registerLazySingleton<AiModelProvisioner>(
    () => AiModelProvisioner(
      storageService: getIt<IFileStorageService>(),
      integrators: [getIt<IAiModelIntegrator>()],
    ),
  );

  getIt.registerSingletonAsync<AiRuntimeInitializer>(() async {
    final runtimeInitializer = AiRuntimeInitializer(
      storageService: getIt<IFileStorageService>(),
      registeredModels: OcrModelCatalog.all,
      readActiveModelId: getIt<AppSettingsService>().getSelectedOcrModelId,
      provisioner: getIt<AiModelProvisioner>(),
      isBackgroundIsolate: isBackgroundIsolate,
    );

    await runtimeInitializer.initialize();
    return runtimeInitializer;
  }, dependsOn: [IFileStorageService, AppSettingsService]);
}
