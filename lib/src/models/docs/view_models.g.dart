// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScannedDocumentGroupModel _$ScannedDocumentGroupModelFromJson(
  Map<String, dynamic> json,
) => ScannedDocumentGroupModel(
  id: json['id'] as String,
  groupName: json['groupName'] as String,
  relativePath: json['relativePath'] as String,
  absolutePath: json['absolutePath'] as String,
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
  'groupName': instance.groupName,
  'relativePath': instance.relativePath,
  'absolutePath': instance.absolutePath,
  'documents': instance.documents.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

ScannedDocumentModel _$ScannedDocumentModelFromJson(
  Map<String, dynamic> json,
) => ScannedDocumentModel(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  name: json['name'] as String,
  relativeFilePath: json['relativeFilePath'] as String,
  absoluteFilePath: json['absoluteFilePath'] as String,
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
  'relativeFilePath': instance.relativeFilePath,
  'absoluteFilePath': instance.absoluteFilePath,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'ext': instance.ext,
};

ScannedDocumentTranscriptionModel _$ScannedDocumentTranscriptionModelFromJson(
  Map<String, dynamic> json,
) => ScannedDocumentTranscriptionModel(
  id: json['id'] as String,
  docId: json['docId'] as String,
  relativeFilePath: json['relativeFilePath'] as String,
  absoluteFilePath: json['absoluteFilePath'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  ext: json['ext'] as String,
  timeMsToTranscribe: (json['timeMsToTranscribe'] as num).toInt(),
  timeMsToRead: (json['timeMsToRead'] as num).toInt(),
  wordCount: (json['wordCount'] as num).toInt(),
);

Map<String, dynamic> _$ScannedDocumentTranscriptionModelToJson(
  ScannedDocumentTranscriptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'docId': instance.docId,
  'relativeFilePath': instance.relativeFilePath,
  'absoluteFilePath': instance.absoluteFilePath,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'ext': instance.ext,
  'timeMsToTranscribe': instance.timeMsToTranscribe,
  'timeMsToRead': instance.timeMsToRead,
  'wordCount': instance.wordCount,
};
