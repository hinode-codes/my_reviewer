import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/docs_main_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/group_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/group_edit_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_transcription_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_viewer_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_groups_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_transcription_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/jobs/ocr_transcription_job_handler.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/local_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/local_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/local_transcription_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/local_transcription_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/edge_ai_qwen_ocr_engine.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_document_scanner_service.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_local_ocr_engine.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/ml_kit_document_scanner_service.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_documents_use_case.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_group_use_case.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_groups_use_case.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/update_scanned_group_use_case.dart';
import 'package:my_reviewer/src/features/settings/controllers/settings_controller.dart';
import 'package:my_reviewer/src/shared/controllers/ai_model_selector_controller.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:my_reviewer/src/shared/db/dao/jobs_dao.dart';
import 'package:my_reviewer/src/shared/models/ocr_models.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/local_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/local_job_write_repository.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_model_provisioner.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_runtime_initializer.dart';
import 'package:my_reviewer/src/shared/services/ai_models/edge_ai_ocr_integrator.dart';
import 'package:my_reviewer/src/shared/services/ai_models/i_ai_model_integrator.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_dispatcher.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_handler.dart';
import 'package:my_reviewer/src/shared/services/jobs/local_job_queue_runner.dart';
import 'package:my_reviewer/src/shared/services/notifications/android_job_notification_service.dart';
import 'package:my_reviewer/src/shared/services/notifications/i_job_notification_service.dart';
import 'package:my_reviewer/src/shared/services/notifications/no_op_job_notification_service.dart';
import 'package:my_reviewer/src/shared/services/sound/i_sound_service.dart';
import 'package:my_reviewer/src/shared/services/sound/so_loud_sound_service.dart';
import 'package:my_reviewer/src/shared/services/storage/disk_file_storage_service.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator({
  NotificationPreferenceReader? isJobNotificationEnabled,
  ModelIdReader? readSelectedOcrModelId,
  ModelIdWriter? writeSelectedOcrModelId,
  WifiOnlyPreferenceReader? readWifiOnlyDownloads,
  WifiOnlyPreferenceWriter? writeWifiOnlyDownloads,
  AuthTokenReader? readHuggingFaceToken,
}) async {
  // --- Core Infrastructure & Storage ---
  final storageService = await DiskFileStorageService.create();

  getIt.registerSingleton<IFileStorageService>(storageService);

  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // --- DAOs ---
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

  // --- Job Repositories ---
  getIt.registerLazySingleton<IJobReadRepository>(
    () => LocalJobReadRepository(dao: getIt<JobDao>()),
  );
  getIt.registerLazySingleton<IJobWriteRepository>(
    () =>
        LocalJobWriteRepository(db: getIt<AppDatabase>(), dao: getIt<JobDao>()),
  );

  // --- Device & Platform Services ---
  getIt.registerLazySingleton<IDocumentScannerService>(
    () => MlKitDocumentScannerService(),
  );
  getIt.registerLazySingleton<ISoundService>(() => SoLoudSoundService());
  getIt.registerLazySingleton<IJobNotificationService>(
    () => Platform.isAndroid
        ? AndroidJobNotificationService(
            isUserNotificationEnabled:
                isJobNotificationEnabled ?? () async => true,
          )
        : const NoopJobNotificationService(),
  );

  // --- Scanned Documents & Transcription Repositories ---
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

  // --- Offline OCR Engine, AI Model Provisioning & Runtime ---
  getIt.registerLazySingleton<ILocalOcrEngine>(
    () => EdgeAiQwenOcrEngine(),
    dispose: (engine) => engine.dispose(),
  );

  await _registerAiModels(
    readSelectedOcrModelId: readSelectedOcrModelId,
    writeSelectedOcrModelId: writeSelectedOcrModelId,
    readWifiOnlyDownloads: readWifiOnlyDownloads,
    writeWifiOnlyDownloads: writeWifiOnlyDownloads,
    readHuggingFaceToken: readHuggingFaceToken,
  );

  // --- Job Handler & Queue Runner ---
  getIt.registerLazySingleton<IJobHandler>(
    () => OcrTranscriptionJobHandler(
      storageService: getIt<IFileStorageService>(),
      ocrEngine: getIt<ILocalOcrEngine>(),
      transcriptionWriteRepo: getIt<ITranscriptionWriteRepository>(),
    ),
  );

  getIt.registerLazySingleton<LocalJobQueueRunner>(
    () => LocalJobQueueRunner(
      readRepo: getIt<IJobReadRepository>(),
      writeRepo: getIt<IJobWriteRepository>(),
      handler: getIt<IJobHandler>(),
      notifications: getIt<IJobNotificationService>(),
    ),
    dispose: (runner) => runner.dispose(),
  );
  getIt.registerLazySingleton<IJobDispatcher>(
    () => getIt<LocalJobQueueRunner>(),
  );

  // --- Use Cases ---
  getIt.registerLazySingleton<DeleteScannedGroupUseCase>(
    () => DeleteScannedGroupUseCase(
      writeRepo: getIt<IScannedDocumentWriteRepository>(),
      transcriptionWriteRepo: getIt<ITranscriptionWriteRepository>(),
      jobDispatcher: getIt<IJobDispatcher>(),
    ),
  );

  getIt.registerLazySingleton<DeleteScannedGroupsUseCase>(
    () => DeleteScannedGroupsUseCase(getIt<DeleteScannedGroupUseCase>()),
  );

  getIt.registerLazySingleton<DeleteScannedDocumentsUseCase>(
    () => DeleteScannedDocumentsUseCase(
      readRepo: getIt<IScannedDocumentReadRepository>(),
      writeRepo: getIt<IScannedDocumentWriteRepository>(),
      transcriptionWriteRepo: getIt<ITranscriptionWriteRepository>(),
      jobDispatcher: getIt<IJobDispatcher>(),
      deleteGroup: getIt<DeleteScannedGroupUseCase>(),
    ),
  );

  getIt.registerLazySingleton<UpdateScannedGroupUseCase>(
    () => UpdateScannedGroupUseCase(
      readRepo: getIt<IScannedDocumentReadRepository>(),
      writeRepo: getIt<IScannedDocumentWriteRepository>(),
      transcriptionWriteRepo: getIt<ITranscriptionWriteRepository>(),
      jobDispatcher: getIt<IJobDispatcher>(),
    ),
  );

  // --- Screen Controllers (Factories, disposed on route pop) ---
  getIt.registerFactory<DocsMainController>(
    () => DocsMainController(
      readRepository: getIt<IScannedDocumentReadRepository>(),
      deleteGroupsUseCase: getIt<DeleteScannedGroupsUseCase>(),
    ),
  );

  getIt.registerFactory<ScanController>(
    () => ScanController(
      writeRepository: getIt<IScannedDocumentWriteRepository>(),
      scanner: getIt<IDocumentScannerService>(),
      storageService: getIt<IFileStorageService>(),
    ),
  );

  getIt.registerFactoryParam<
    GroupEditController,
    String,
    ScannedDocumentGroupModel?
  >((groupId, initialGroup) {
    return GroupEditController(
      readRepository: getIt<IScannedDocumentReadRepository>(),
      updateGroupUseCase: getIt<UpdateScannedGroupUseCase>(),
      deleteGroupsUseCase: getIt<DeleteScannedGroupsUseCase>(),
      scanner: getIt<IDocumentScannerService>(),
      storageService: getIt<IFileStorageService>(),
      groupId: groupId,
      initialGroup: initialGroup,
    );
  });

  getIt.registerFactoryParam<GroupController, GroupRouteArgs, void>((args, _) {
    return GroupController(
      readRepository: getIt<IScannedDocumentReadRepository>(),
      deleteDocumentsUseCase: getIt<DeleteScannedDocumentsUseCase>(),
      groupId: args.groupId,
      initialDocuments: args.initialDocuments,
    );
  });

  getIt.registerFactoryParam<PageViewerController, DocsPageViewerArgs, void>((
    args,
    _,
  ) {
    return PageViewerController(
      readRepository: getIt<IScannedDocumentReadRepository>(),
      storageService: getIt<IFileStorageService>(),
      groupId: args.groupId,
      docId: args.docId,
      initialDocuments: args.initialDocuments,
    );
  });

  getIt.registerFactoryParam<PageTranscriptionController, String, void>((
    groupId,
    _,
  ) {
    return PageTranscriptionController(
      groupId: groupId,
      transcriptionReadRepo: getIt<ITranscriptionReadRepository>(),
      jobReadRepo: getIt<IJobReadRepository>(),
      jobDispatcher: getIt<IJobDispatcher>(),
      storageService: getIt<IFileStorageService>(),
    );
  });
}

Future<void> _registerAiModels({
  ModelIdReader? readSelectedOcrModelId,
  ModelIdWriter? writeSelectedOcrModelId,
  WifiOnlyPreferenceReader? readWifiOnlyDownloads,
  WifiOnlyPreferenceWriter? writeWifiOnlyDownloads,
  AuthTokenReader? readHuggingFaceToken,
}) async {
  String? inMemorySelectedId;
  bool inMemoryWifiOnly = true;

  final readModelId = readSelectedOcrModelId ?? () async => inMemorySelectedId;
  final writeModelId =
      writeSelectedOcrModelId ??
      (String id) async {
        inMemorySelectedId = id;
      };

  final readWifiOnly = readWifiOnlyDownloads ?? () async => inMemoryWifiOnly;
  final writeWifiOnly =
      writeWifiOnlyDownloads ??
      (bool value) async {
        inMemoryWifiOnly = value;
      };

  final runtimeInitializer = AiRuntimeInitializer(
    storageService: getIt<IFileStorageService>(),
    registeredModels: OcrModelCatalog.all,
    readActiveModelId: readModelId,
  );
  await runtimeInitializer.initialize();
  getIt.registerSingleton<AiRuntimeInitializer>(runtimeInitializer);

  getIt.registerLazySingleton<IAiModelIntegrator>(
    () => EdgeAiOcrModelIntegrator(ocrEngine: getIt<ILocalOcrEngine>()),
  );

  getIt.registerLazySingleton<AiModelProvisioner>(
    () => AiModelProvisioner(
      storageService: getIt<IFileStorageService>(),
      integrators: [getIt<IAiModelIntegrator>()],
    ),
  );

  getIt.registerLazySingleton<AiModelSelectorController>(
    () => AiModelSelectorController(
      models: OcrModelCatalog.all,
      provisioner: getIt<AiModelProvisioner>(),
      readSelectedModelId: readModelId,
      writeSelectedModelId: writeModelId,
      readWifiOnly: readWifiOnly,
      readAuthToken: readHuggingFaceToken,
    ),
    dispose: (controller) => controller.dispose(),
  );

  getIt.registerLazySingleton<SettingsController>(
    () => SettingsController(
      readWifiOnly: readWifiOnly,
      writeWifiOnly: writeWifiOnly,
    ),
    dispose: (controller) => controller.dispose(),
  );
}
