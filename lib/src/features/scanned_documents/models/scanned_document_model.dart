import 'package:json_annotation/json_annotation.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';

part "scanned_document_model.g.dart";

@JsonSerializable()
class ScannedDocumentModel {
  final String id;
  final String groupId;
  final String name;
  final String relativePath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String ext;

  const ScannedDocumentModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.relativePath,
    required this.createdAt,
    this.updatedAt,
    required this.ext,
  });

  factory ScannedDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$ScannedDocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedDocumentModelToJson(this);

  ScannedDocumentModel copyWith({
    String? id,
    String? groupId,
    String? name,
    String? relativePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ext,
  }) {
    return ScannedDocumentModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      relativePath: relativePath ?? this.relativePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ext: ext ?? this.ext,
    );
  }

  ScannedDocumentModel clone() {
    return ScannedDocumentModel(
      id: id,
      groupId: groupId,
      name: name,
      relativePath: relativePath,
      createdAt: createdAt,
      ext: ext,
    );
  }

  @override
  int get hashCode =>
      Object.hash(id, groupId, name, relativePath, createdAt, updatedAt, ext);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedDocumentModel &&
          other.id == id &&
          other.groupId == groupId &&
          other.name == name &&
          other.relativePath == relativePath &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.ext == ext;

  static String fallbackFileName(String groupName, int pageNumber) {
    final safeGroupName = sanitizeFileName(groupName, groupName);

    return '${safeGroupName}_Page_${pageNumber + 1}';
  }
}
