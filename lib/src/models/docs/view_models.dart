import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_reviewer/src/utils/string.dart';

part 'view_models.g.dart';

@JsonSerializable(explicitToJson: true)
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

  factory ScannedDocumentGroupModel.fromJson(Map<String, dynamic> json) =>
      _$ScannedDocumentGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedDocumentGroupModelToJson(this);

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

@JsonSerializable()
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

  factory ScannedDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$ScannedDocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedDocumentModelToJson(this);

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

@JsonSerializable()
class ScannedDocumentTranscriptionModel {
  final String id;
  final String docId;
  final String relativeFilePath;
  final String absoluteFilePath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String ext;
  final int timeMsToTranscribe;
  final int timeMsToRead;
  final int wordCount;

  const ScannedDocumentTranscriptionModel({
    required this.id,
    required this.docId,
    required this.relativeFilePath,
    required this.absoluteFilePath,
    required this.createdAt,
    this.updatedAt,
    required this.ext,
    required this.timeMsToTranscribe,
    required this.timeMsToRead,
    required this.wordCount,
  });

  factory ScannedDocumentTranscriptionModel.fromJson(
    Map<String, dynamic> json,
  ) => _$ScannedDocumentTranscriptionModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ScannedDocumentTranscriptionModelToJson(this);

  ScannedDocumentTranscriptionModel copyWith({
    String? id,
    String? docId,
    String? relativeFilePath,
    String? absoluteFilePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ext,
    int? timeMsToTranscribe,
    int? timeMsToRead,
    int? wordCount,
  }) {
    return ScannedDocumentTranscriptionModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      relativeFilePath: relativeFilePath ?? this.relativeFilePath,
      absoluteFilePath: absoluteFilePath ?? this.absoluteFilePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ext: ext ?? this.ext,
      timeMsToTranscribe: timeMsToTranscribe ?? this.timeMsToTranscribe,
      timeMsToRead: timeMsToRead ?? this.timeMsToRead,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedDocumentTranscriptionModel &&
          other.id == id &&
          other.docId == docId &&
          other.relativeFilePath == relativeFilePath &&
          other.absoluteFilePath == absoluteFilePath &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.ext == ext &&
          other.timeMsToTranscribe == timeMsToTranscribe &&
          other.timeMsToRead == timeMsToRead &&
          other.wordCount == wordCount;

  @override
  int get hashCode => Object.hash(
    id,
    docId,
    relativeFilePath,
    absoluteFilePath,
    createdAt,
    updatedAt,
    ext,
    timeMsToTranscribe,
    timeMsToRead,
    wordCount,
  );
}
