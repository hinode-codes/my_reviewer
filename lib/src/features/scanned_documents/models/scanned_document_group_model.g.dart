// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_document_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScannedDocumentGroupModel _$ScannedDocumentGroupModelFromJson(
  Map<String, dynamic> json,
) => ScannedDocumentGroupModel(
  id: json['id'] as String,
  name: json['name'] as String,
  relativePath: json['relativePath'] as String,
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => ScannedDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ScannedDocumentGroupModelToJson(
  ScannedDocumentGroupModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'relativePath': instance.relativePath,
  'documents': instance.documents.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
