import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:my_reviewer/src/controllers/background_progress_banner_controller.dart';
import 'package:my_reviewer/src/controllers/docs/docs_controller.dart';
import 'package:my_reviewer/src/controllers/docs/docs_scan_controller.dart';
import 'package:my_reviewer/src/controllers/docs/group_controller.dart';
import 'package:my_reviewer/src/controllers/docs/group_edit_controller.dart';
import 'package:my_reviewer/src/controllers/docs/page_viewer_controller.dart';
import 'package:my_reviewer/src/controllers/docs/transcription_viewer_controller.dart';
import 'package:my_reviewer/src/controllers/jobs/jobs_controller.dart';
import 'package:my_reviewer/src/controllers/settings_controller.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/dao/docs_dao.dart';
import 'package:my_reviewer/src/db/dao/jobs_dao.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/repositories/jobs/impl.dart';
import 'package:my_reviewer/src/repositories/jobs/interface.dart';
import 'package:my_reviewer/src/repositories/scanned_document/impl.dart';
import 'package:my_reviewer/src/repositories/scanned_document/interface.dart';
import 'package:my_reviewer/src/repositories/transcription/impl.dart';
import 'package:my_reviewer/src/repositories/transcription/interface.dart';
import 'package:my_reviewer/src/services/document_scanner_service.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';
import 'package:my_reviewer/src/services/ui_sound_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // --- Core Infrastructure & Storage ---
  getIt.registerLazySingleton<FileStorageService>(() => FileStorageService());
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // --- DAOs ---
  getIt.registerLazySingleton<ScannedDocumentsDao>(
    () => ScannedDocumentsDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<JobsDao>(() => JobsDao(getIt<AppDatabase>()));

  // --- Repositories ---
  getIt.registerLazySingleton<IScannedDocumentRepository>(
    () => LocalScannedDocumentRepository(
      dao: getIt<ScannedDocumentsDao>(),
      storageService: getIt<FileStorageService>(),
      transcriptionRepo: getIt<ITranscriptionRepository>(),
      jobQueue: getIt<IJobQueue>(),
    ),
  );
  getIt.registerLazySingleton<ITranscriptionRepository>(
    () => LocalTranscriptionRepository(
      dao: getIt<ScannedDocumentsDao>(),
      storage: getIt<FileStorageService>(),
    ),
  );

  // --- Device & Platform Services ---
  getIt.registerLazySingleton<IDocumentScannerService>(
    () => MlKitDocumentScannerService(),
  );
  getIt.registerLazySingleton<IUiSoundService>(() => SoLoudUiSoundService());
  getIt.registerLazySingleton<IBackgroundKeepAlive>(
    () => Platform.isAndroid
        ? AndroidForegroundKeepAlive()
        : const NoopBackgroundKeepAlive(),
  );

  // --- Offline OCR Engines & Handlers ---
  getIt.registerLazySingleton<QwenGgufEngine>(
    () => QwenGgufEngine(getIt<FileStorageService>()),
  );
  getIt.registerLazySingleton<TranscriptionEngineRegistry>(
    () => TranscriptionEngineRegistry([getIt<QwenGgufEngine>()]),
  );
  getIt.registerLazySingleton<TranscribePageHandler>(
    () => TranscribePageHandler(
      engineRegistry: getIt<TranscriptionEngineRegistry>(),
      storage: getIt<FileStorageService>(),
      transcriptionRepo: getIt<ITranscriptionRepository>(),
      jobsDao: getIt<JobsDao>(),
      keepAlive: getIt<IBackgroundKeepAlive>(),
    ),
  );

  // --- Background Downloader & Job Queue ---
  getIt.registerLazySingleton<IModelDownloader>(
    () => BackgroundModelDownloader(getIt<FileStorageService>()),
  );
  getIt.registerLazySingleton<IJobQueue>(
    () => DriftJobQueue(getIt<JobsDao>(), [
      getIt<TranscribePageHandler>(),
    ], getIt<IBackgroundKeepAlive>()),
  );

  // --- App-Wide Controllers (Singletons) ---
  getIt.registerLazySingleton<SettingsController>(() => SettingsController());
  getIt.registerLazySingleton<BackgroundProgressBannerController>(
    () => BackgroundProgressBannerController(),
  );

  // --- Screen Controllers (Factories, disposed on route pop) ---
  getIt.registerFactory<DocsController>(
    () => DocsController(getIt<IScannedDocumentRepository>()),
  );

  getIt.registerFactory<JobsController>(() {
    const buildHfToken = String.fromEnvironment('HF_TOKEN');
    final userToken =
        "" as String?; //getIt<SettingsController>().huggingFaceToken?.trim();
    final token = (userToken != null && userToken.isNotEmpty)
        ? userToken
        : (buildHfToken.isNotEmpty ? buildHfToken : null);

    return JobsController(
      getIt<IJobQueue>(),
      getIt<BackgroundProgressBannerController>(),
      getIt<IModelDownloader>(),
      authToken: token,
    );
  });

  getIt.registerFactory<DocsScanController>(
    () => DocsScanController(
      repository: getIt<IScannedDocumentRepository>(),
      scanner: getIt<IDocumentScannerService>(),
      storageService: getIt<FileStorageService>(),
    ),
  );

  getIt.registerFactoryParam<
    GroupEditController,
    String,
    ScannedDocumentGroupModel?
  >((docId, initialGroup) {
    return GroupEditController(
      repository: getIt<IScannedDocumentRepository>(),
      scanner: getIt<IDocumentScannerService>(),
      storageService: getIt<FileStorageService>(),
      docId: docId,
      initialGroup: initialGroup,
    );
  });

  getIt.registerFactoryParam<DocsGroupController, DocsGroupArgs, void>((
    args,
    _,
  ) {
    return DocsGroupController(
      repository: getIt<IScannedDocumentRepository>(),
      docId: args.docId,
      initialDocuments: args.initialDocuments,
    );
  });

  getIt
      .registerFactoryParam<DocsPageViewerController, DocsPageViewerArgs, void>(
        (args, _) {
          return DocsPageViewerController(
            repository: getIt<IScannedDocumentRepository>(),
            groupId: args.groupId,
            docId: args.docId,
            initialDocuments: args.initialDocuments,
          );
        },
      );

  getIt.registerFactoryParam<
    TranscriptionViewerController,
    TranscriptionViewerArgs,
    void
  >((args, _) {
    return TranscriptionViewerController(
      groupId: args.groupId,
      docId: args.docId,
      documentRepo: getIt<IScannedDocumentRepository>(),
      transcriptionRepo: getIt<ITranscriptionRepository>(),
      jobQueue: getIt<IJobQueue>(),
      storage: getIt<FileStorageService>(),
      initialDocuments: args.initialDocuments,
    );
  });
}
