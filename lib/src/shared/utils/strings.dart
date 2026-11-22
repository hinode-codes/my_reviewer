import 'package:uuid/v7.dart';

String generateId() {
  return UuidV7().generate();
}

String sanitizeFileName(String name, String fallback) {
  final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  return sanitized.isEmpty ? fallback : sanitized;
}

/// Why a user-entered name is or is not acceptable.
///
/// An enum rather than a bool so that new rules (too long, illegal
/// characters, duplicate) become new values that every `switch` must handle.
enum NameValidation { valid, empty }

NameValidation validateName(String name) {
  if (name.trim().isEmpty) {
    return NameValidation.empty;
  }

  return NameValidation.valid;
}
