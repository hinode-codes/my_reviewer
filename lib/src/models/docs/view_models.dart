import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/utils/string.dart';

class ScannedDocumentGroupModel {
  final String id;
  final String groupName;
  final String relativePath;
  final String absolutePath;
  final List<ScannedDocumentModel> documents;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ScannedDocumentGroupModel({
    required this.id,
    required this.groupName,
    required this.relativePath,
    required this.absolutePath,
    this.documents = const [],
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedDocumentGroupModel &&
          other.id == id &&
          other.groupName == groupName &&
          other.relativePath == relativePath &&
          other.absolutePath == absolutePath &&
          listEquals(other.documents, documents) &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    groupName,
    relativePath,
    absolutePath,
    Object.hashAll(documents),
    createdAt,
    updatedAt,
  );
}

class ScannedDocumentModel {
  final String id;
  final String groupId;
  final String name;
  final String relativeFilePath;
  final String absoluteFilePath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String ext;

  const ScannedDocumentModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.relativeFilePath,
    required this.absoluteFilePath,
    required this.createdAt,
    this.updatedAt,
    required this.ext,
  });

  static String fallbackFileName(String groupName, int pageNumber) {
    final safeGroupName = sanitizeFileName(groupName, groupName);

    return '${safeGroupName}_Page_${pageNumber + 1}';
  }

  ScannedDocumentModel copyWith({
    String? id,
    String? groupId,
    String? name,
    String? relativeFilePath,
    String? absoluteFilePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ext,
  }) {
    return ScannedDocumentModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      relativeFilePath: relativeFilePath ?? this.relativeFilePath,
      absoluteFilePath: absoluteFilePath ?? this.absoluteFilePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ext: ext ?? this.ext,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedDocumentModel &&
          other.id == id &&
          other.groupId == groupId &&
          other.name == name &&
          other.relativeFilePath == relativeFilePath &&
          other.absoluteFilePath == absoluteFilePath &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.ext == ext;

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    name,
    relativeFilePath,
    absoluteFilePath,
    createdAt,
    updatedAt,
    ext,
  );
}
