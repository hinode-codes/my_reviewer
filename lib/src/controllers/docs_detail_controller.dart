import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/repositories/scanned_document_repository.dart';
import 'package:my_reviewer/src/repositories/scanned_document_repository_impl.dart';

class DocsDetailController extends ChangeNotifier {
  final String docId;
  final String docName;
  final IScannedDocumentRespository repository;

  DocsDetailController({required this.docId, required this.docName})
    : repository = getIt<LocalScannedDocumentRepository>();

  Stream<List<ScannedDocumentModel>> watchScannedDocument() {
    return repository.watchScannedDocumentsByGroupId(docId);
  }
}
