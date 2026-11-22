import 'package:drift/drift.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';

mixin IdMetadataMixin on Table {
  TextColumn get id => text().clientDefault(() => generateId())();

  @override
  Set<Column> get primaryKey => {id};
}
