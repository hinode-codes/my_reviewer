import 'package:get_it/get_it.dart';
import 'package:my_reviewer/src/controllers/docs_controller.dart';
import 'package:my_reviewer/src/controllers/docs_detail_controller.dart';
import 'package:my_reviewer/src/controllers/docs_scan_controller.dart';
import 'package:my_reviewer/src/controllers/settings_controller.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/dao/docs_dao.dart';
import 'package:my_reviewer/src/repositories/scanned_document_repository_impl.dart';
import 'package:my_reviewer/src/services/document_scanner_service.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<FileStorageService>(() => FileStorageService());
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<ScannedDocumentsDao>(
    () => ScannedDocumentsDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<LocalScannedDocumentRepository>(
    () => LocalScannedDocumentRepository(
      dao: getIt<ScannedDocumentsDao>(),
      storageService: getIt<FileStorageService>(),
    ),
  );

  getIt.registerFactory<DocsScanController>(
    () => DocsScanController(
      MlKitDocumentScannerService(),
      getIt<LocalScannedDocumentRepository>(),
    ),
  );
  getIt.registerFactory<DocsController>(
    () => DocsController(getIt<LocalScannedDocumentRepository>()),
  );
  getIt.registerLazySingleton<SettingsController>(() => SettingsController());
  getIt.registerFactoryParam<DocsDetailController, String, String>(
    (docId, docName) => DocsDetailController(docId: docId, docName: docName),
  );
}
