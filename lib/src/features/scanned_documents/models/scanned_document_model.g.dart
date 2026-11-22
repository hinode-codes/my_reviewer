// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScannedDocumentModel _$ScannedDocumentModelFromJson(
  Map<String, dynamic> json,
) => ScannedDocumentModel(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  name: json['name'] as String,
  relativePath: json['relativePath'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  ext: json['ext'] as String,
);

Map<String, dynamic> _$ScannedDocumentModelToJson(
  ScannedDocumentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'name': instance.name,
  'relativePath': instance.relativePath,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'ext': instance.ext,
};
