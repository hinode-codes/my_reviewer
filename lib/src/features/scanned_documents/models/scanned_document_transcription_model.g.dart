// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_document_transcription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScannedDocumentTranscriptionModel _$ScannedDocumentTranscriptionModelFromJson(
  Map<String, dynamic> json,
) => ScannedDocumentTranscriptionModel(
  id: json['id'] as String,
  docId: json['docId'] as String,
  relativePath: json['relativePath'] as String,
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
  'relativePath': instance.relativePath,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'ext': instance.ext,
  'timeMsToTranscribe': instance.timeMsToTranscribe,
  'timeMsToRead': instance.timeMsToRead,
  'wordCount': instance.wordCount,
};
