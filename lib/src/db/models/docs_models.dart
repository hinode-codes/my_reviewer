import 'package:drift/drift.dart';
import 'package:my_reviewer/src/utils/string.dart';

mixin DateMetadataMixins on Table {
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class ScannedDocumentsGroups extends Table with DateMetadataMixins {
  TextColumn get id => text().clientDefault(() => generateId())();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get relativeFolderPath => text()();
  TextColumn get absoluteFolderPath => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ScannedDocuments extends Table with DateMetadataMixins {
  TextColumn get id => text().clientDefault(() => generateId())();
  TextColumn get groupId => text().references(
    ScannedDocumentsGroups,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get relativeImagePath => text()();
  TextColumn get absoluteImagePath => text()();

  @override
  Set<Column> get primaryKey => {id};
}
