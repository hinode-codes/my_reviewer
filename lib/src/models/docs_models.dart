import 'package:my_reviewer/src/utils/string.dart';

class ScannedDocumentGroupModel {
  final String id;
  final String groupName;
  final String relativeFolderPath;
  final String absoluteFolderPath;
  final List<ScannedDocumentModel> documents;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ScannedDocumentGroupModel({
    required this.id,
    required this.groupName,
    required this.relativeFolderPath,
    required this.absoluteFolderPath,
    this.documents = const [],
    required this.createdAt,
    this.updatedAt,
  });
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
}
