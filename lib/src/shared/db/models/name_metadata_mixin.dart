import 'package:drift/drift.dart';

mixin NameMetadataMixin on Table {
  TextColumn get name => text().withLength(min: 1, max: 255)();
}
