import 'dart:math' as math;

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

/// Formats [bytes] into a human-readable string (e.g., `"500 MB"`, `"1.45 GB"`).
String formatByteSize(
  int bytes, {
  int base = 1024,
  List<String> units = const ['B', 'KB', 'MB', 'GB', 'TB', 'PB'],
  int minUnitIndex = 0,
  int? decimals,
  String separator = ' ',
}) {
  assert(base > 1);
  assert(units.isNotEmpty);
  assert(minUnitIndex >= 0 && minUnitIndex < units.length);

  if (bytes <= 0) {
    return '0$separator${units[minUnitIndex]}';
  }

  final rawIndex = (math.log(bytes) / math.log(base)).floor();
  final unitIndex = rawIndex.clamp(minUnitIndex, units.length - 1);
  final value = bytes / math.pow(base, unitIndex);
  final precision = decimals ?? (unitIndex >= 3 ? 2 : 0);

  return '${value.toStringAsFixed(precision)}$separator${units[unitIndex]}';
}
