import 'package:get_it/get_it.dart';
import 'package:my_reviewer/src/controllers/docs/docs_controller.dart';
import 'package:my_reviewer/src/controllers/docs/docs_scan_controller.dart';
import 'package:my_reviewer/src/controllers/docs/group_controller.dart';
import 'package:my_reviewer/src/controllers/docs/group_edit_controller.dart';
import 'package:my_reviewer/src/controllers/docs/page_viewer_controller.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/dao/docs_dao.dart';
import 'package:my_reviewer/src/controllers/settings_controller.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/repositories/scanned_document/impl.dart';
import 'package:my_reviewer/src/repositories/scanned_document/interface.dart';
import 'package:my_reviewer/src/services/document_scanner_service.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<FileStorageService>(() => FileStorageService());
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<ScannedDocumentsDao>(
    () => ScannedDocumentsDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IScannedDocumentRepository>(
    () => LocalScannedDocumentRepository(
      dao: getIt<ScannedDocumentsDao>(),
      storageService: getIt<FileStorageService>(),
    ),
  );
  getIt.registerLazySingleton<IDocumentScannerService>(
    () => MlKitDocumentScannerService(),
  );

  getIt.registerFactory<DocsController>(() {
    final repository = getIt<IScannedDocumentRepository>();

    return DocsController(repository);
  });

  getIt.registerFactory<SettingsController>(() {
    return SettingsController();
  });

  getIt.registerFactory<DocsScanController>(() {
    return DocsScanController(
      repository: getIt<IScannedDocumentRepository>(),
      scanner: getIt<IDocumentScannerService>(),
      storageService: getIt<FileStorageService>(),
    );
  });

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
    final repository = getIt<IScannedDocumentRepository>();

    return DocsGroupController(
      repository: repository,
      docId: args.docId,
      initialDocuments: args.initialDocuments,
    );
  });

  getIt.registerFactoryParam<DocsPageViewerController, DocsPageViewerArgs, void>(
    (args, _) {
      return DocsPageViewerController(
        repository: getIt<IScannedDocumentRepository>(),
        groupId: args.groupId,
        docId: args.docId,
        initialDocuments: args.initialDocuments,
      );
    },
  );
}