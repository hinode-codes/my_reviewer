import 'package:drift/drift.dart';

mixin PathMetadataMixin on Table {
  TextColumn get relativePath => text()();
}
