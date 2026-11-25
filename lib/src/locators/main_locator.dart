import 'package:get_it/get_it.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/docs_main_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/group_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/group_edit_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_transcription.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_viewer_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/i_document_scanner_service.dart';
import 'package:my_reviewer/src/features/scanned_documents/services/ml_kit_document_scanner_service.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_documents_use_case.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_group_use_case.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_groups_use_case.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/save_and_transcribe_documents_use_case.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/update_scanned_group_use_case.dart';
import 'package:my_reviewer/src/features/settings/controllers/settings_controller.dart';
import 'package:my_reviewer/src/locators/shared_locators.dart';
import 'package:my_reviewer/src/shared/controllers/ai_model_selector_controller.dart';
import 'package:my_reviewer/src/shared/models/ocr_models.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_model_provisioner.dart';
import 'package:my_reviewer/src/shared/services/app_settings_service.dart';
import 'package:my_reviewer/src/shared/services/sound/i_sound_service.dart';
import 'package:my_reviewer/src/shared/services/sound/so_loud_sound_service.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  setupCoreLocators(getIt);

  getIt.registerSingletonAsync<ISoundService>(() async {
    final service = SoLoudSoundService();
    await service.initialize();
    return service;
  }, dispose: (service) => service.dispose());

  // --- Synchronous Lazy Singletons ---
  getIt.registerLazySingleton<IDocumentScannerService>(
    () => MlKitDocumentScannerService(),
    dispose: (service) => service.dispose(),
  );

  // --- Use Cases ---
  getIt.registerLazySingleton<DeleteScannedGroupUseCase>(
    () => DeleteScannedGroupUseCase(
      writeRepo: getIt<IScannedDocumentWriteRepository>(),
      transcriptionWriteRepo: getIt<ITranscriptionWriteRepository>(),
      jobWriteRepository: getIt<IJobWriteRepository>(),
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
      jobWriteRepo: getIt<IJobWriteRepository>(),
      deleteGroup: getIt<DeleteScannedGroupUseCase>(),
    ),
  );

  getIt.registerLazySingleton<UpdateScannedGroupUseCase>(
    () => UpdateScannedGroupUseCase(
      readRepo: getIt<IScannedDocumentReadRepository>(),
      writeRepo: getIt<IScannedDocumentWriteRepository>(),
      transcriptionWriteRepo: getIt<ITranscriptionWriteRepository>(),
      jobWriteRepo: getIt<IJobWriteRepository>(),
    ),
  );

  getIt.registerLazySingleton<SaveScannedGroupUseCase>(
    () => SaveScannedGroupUseCase(
      readRepo: getIt<IScannedDocumentReadRepository>(),
      writeRepo: getIt<IScannedDocumentWriteRepository>(),
      jobWriteRepo: getIt<IJobWriteRepository>(),
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
      saveScannedGroupUseCase: getIt<SaveScannedGroupUseCase>(),
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
      transcriptionReadRepository: getIt<ITranscriptionReadRepository>(),
      jobReadRepository: getIt<IJobReadRepository>(),
      jobWriteRepository: getIt<IJobWriteRepository>(),
      storageService: getIt<IFileStorageService>(),
    );
  });

  getIt.registerLazySingleton<AiModelSelectorController>(
    () => AiModelSelectorController(
      models: OcrModelCatalog.all,
      provisioner: getIt<AiModelProvisioner>(),
      settingsService: getIt<AppSettingsService>(),
    ),
    dispose: (controller) => controller.dispose(),
  );

  getIt.registerLazySingleton<SettingsController>(
    () => SettingsController(settingsService: getIt<AppSettingsService>()),
    dispose: (controller) => controller.dispose(),
  );

  // Wait for all registerSingletonAsync services (including dependsOn chains) to finish
  await getIt.allReady();
}
