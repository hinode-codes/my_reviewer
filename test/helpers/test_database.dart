import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_reviewer/src/db/app_database.dart';

/// A fresh in-memory database. Close it in tearDown.
///
/// Assumes AppDatabase takes its connection as a constructor argument,
/// drift's recommended setup for tests.
AppDatabase createTestDatabase() => AppDatabase(
  DatabaseConnection(
    NativeDatabase.memory(),
    // Drift's advice for Flutter tests: no pending async work may remain
    // when a test ends.
    closeStreamsSynchronously: true,
  ),
);