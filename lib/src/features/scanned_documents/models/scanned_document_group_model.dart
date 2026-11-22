import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'scanned_document_model.dart';

part "scanned_document_group_model.g.dart";

@JsonSerializable(explicitToJson: true)
class ScannedDocumentGroupModel {
  final String id;
  final String name;
  final String relativePath;
  final List<ScannedDocumentModel> documents;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ScannedDocumentGroupModel({
    required this.id,
    required this.name,
    required this.relativePath,
    this.documents = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory ScannedDocumentGroupModel.fromJson(Map<String, dynamic> json) =>
      _$ScannedDocumentGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedDocumentGroupModelToJson(this);

  ScannedDocumentGroupModel copyWith({
    String? id,
    String? name,
    String? relativePath,
    List<ScannedDocumentModel>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScannedDocumentGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      relativePath: relativePath ?? this.relativePath,
      documents: documents ?? this.documents.map((d) => d.clone()).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ScannedDocumentGroupModel clone() {
    return ScannedDocumentGroupModel(
      id: id,
      name: name,
      relativePath: relativePath,
      documents: documents.map((d) => d.clone()).toList(),
      createdAt: createdAt,
    );
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    relativePath,
    Object.hashAll(documents),
    createdAt,
    updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedDocumentGroupModel &&
          other.id == id &&
          other.name == name &&
          other.relativePath == relativePath &&
          listEquals(other.documents, documents) &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;
}
