import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:path/path.dart' as p;

class ScannedDocumentRowMapper {
  const ScannedDocumentRowMapper({required this._docsDao});

  final ScannedDocumentDao _docsDao;

  Future<List<ScannedDocumentGroupModel>> groups(
    List<ScannedDocumentGroupsDbModelData> rows,
  ) async {
    return [for (final row in rows) await group(row)];
  }

  Future<ScannedDocumentGroupModel> group(
    ScannedDocumentGroupsDbModelData row,
  ) async {
    final docRows = await _docsDao.getDocumentsForGroup(row.id);

    return ScannedDocumentGroupModel(
      id: row.id,
      name: row.name,
      relativePath: row.relativePath,
      documents: documents(docRows),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  List<ScannedDocumentModel> documents(List<ScannedDocumentsDbModelData> rows) {
    return [
      for (final row in rows)
        ScannedDocumentModel(
          id: row.id,
          groupId: row.groupId,
          name: row.name,
          relativePath: row.relativePath,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          ext: p.extension(row.relativePath).replaceFirst('.', ''),
        ),
    ];
  }
}
