import 'package:drift/drift.dart';
import 'package:my_reviewer/src/utils/string.dart';

mixin DateMetadataMixins on Table {
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

mixin PathMetadataMixins on Table {
  TextColumn get relativePath => text()();
  TextColumn get absolutePath => text()();
}

mixin FileMetadataMixins on Table {
  TextColumn get ext => text().withLength(min: 1, max: 10)();
}

class ScannedDocumentsGroups extends Table
    with DateMetadataMixins, PathMetadataMixins {
  TextColumn get id => text().clientDefault(() => generateId())();
  TextColumn get name => text().withLength(min: 1, max: 255)();

  @override
  Set<Column> get primaryKey => {id};
}

class ScannedDocuments extends Table
    with DateMetadataMixins, PathMetadataMixins, FileMetadataMixins {
  TextColumn get id => text().clientDefault(() => generateId())();
  TextColumn get groupId => text().references(
    ScannedDocumentsGroups,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get name => text().withLength(min: 1, max: 255)();

  @override
  Set<Column> get primaryKey => {id};
}

class ScannedDocumentTranscriptions extends Table
    with DateMetadataMixins, PathMetadataMixins, FileMetadataMixins {
  TextColumn get id => text().clientDefault(() => generateId())();
  TextColumn get documentId =>
      text().references(ScannedDocuments, #id, onDelete: KeyAction.cascade)();
  IntColumn get timeMsToTranscribe =>
      integer().withDefault(const Constant(0))();
  IntColumn get timeMsToRead => integer().withDefault(const Constant(0))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
