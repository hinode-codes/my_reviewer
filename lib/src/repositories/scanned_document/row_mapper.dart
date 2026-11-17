import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/dao/docs_dao.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';
import 'package:path/path.dart' as p;

/// Maps database rows to domain models while dynamically resolving runtime
/// absolute paths.
class ScannedDocumentRowMapper {
  const ScannedDocumentRowMapper({required this._dao, required this._storage});

  final ScannedDocumentsDao _dao;
  final FileStorageService _storage;

  Future<List<ScannedDocumentGroupModel>> groups(
    List<ScannedDocumentsGroup> rows,
  ) async {
    final result = <ScannedDocumentGroupModel>[];

    for (final row in rows) {
      result.add(await group(row));
    }

    return result;
  }

  Future<ScannedDocumentGroupModel> group(ScannedDocumentsGroup row) async {
    final docRows = await _dao.getDocumentsForGroup(row.id);

    return ScannedDocumentGroupModel(
      id: row.id,
      groupName: row.name,
      relativePath: row.relativePath,
      absolutePath: row.absolutePath,
      documents: await documents(docRows),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<List<ScannedDocumentModel>> documents(
    List<ScannedDocument> rows,
  ) async {
    final models = <ScannedDocumentModel>[];

    for (final row in rows) {
      final runtimeAbsolutePath = await _storage.resolveAbsolutePath(
        row.relativePath,
      );

      final ext = p.extension(row.relativePath).replaceFirst('.', '');

      models.add(
        ScannedDocumentModel(
          id: row.id,
          groupId: row.groupId,
          name: row.name,
          relativeFilePath: row.relativePath,
          absoluteFilePath: runtimeAbsolutePath,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          ext: ext,
        ),
      );
    }

    return models;
  }
}
