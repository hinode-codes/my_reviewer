// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_job_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OcrJobPayload _$OcrJobPayloadFromJson(Map<String, dynamic> json) =>
    OcrJobPayload(
      docId: json['docId'] as String,
      groupId: json['groupId'] as String,
      relativePath: json['relativePath'] as String,
      ext: json['ext'] as String? ?? 'txt',
    );

Map<String, dynamic> _$OcrJobPayloadToJson(OcrJobPayload instance) =>
    <String, dynamic>{
      'docId': instance.docId,
      'groupId': instance.groupId,
      'relativePath': instance.relativePath,
      'ext': instance.ext,
    };
