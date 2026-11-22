// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscribePagePayload _$TranscribePagePayloadFromJson(
  Map<String, dynamic> json,
) => TranscribePagePayload(
  docId: json['docId'] as String,
  groupId: json['groupId'] as String,
  documentName: json['documentName'] as String,
  imageRelativePath: json['imageRelativePath'] as String,
  engineId:
      $enumDecodeNullable(
        _$TranscriptionEngineIdEnumMap,
        json['engineId'],
        unknownValue: TranscriptionEngineId.qwenGguf,
      ) ??
      TranscriptionEngineId.qwenGguf,
);

Map<String, dynamic> _$TranscribePagePayloadToJson(
  TranscribePagePayload instance,
) => <String, dynamic>{
  'docId': instance.docId,
  'groupId': instance.groupId,
  'documentName': instance.documentName,
  'imageRelativePath': instance.imageRelativePath,
  'engineId': _$TranscriptionEngineIdEnumMap[instance.engineId]!,
};

const _$TranscriptionEngineIdEnumMap = {
  TranscriptionEngineId.qwenGguf: 'qwen_gguf',
};
