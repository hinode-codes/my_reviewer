import 'package:drift/drift.dart';

mixin ExtMetadataMixin on Table {
  TextColumn get ext => text().withLength(min: 1, max: 10)();
}
