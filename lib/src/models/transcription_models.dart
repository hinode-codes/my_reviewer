import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'transcription_models.g.dart';

/// Where one page's transcription is in its life.
enum TranscriptionStatus { idle, streaming, saving, saved, failed }

/// How a finished transcription ended.
enum TranscriptionOutcome { completed, stoppedAsRunaway }

@JsonEnum(fieldRename: FieldRename.snake)
enum TranscriptionEngineId {
  qwenGguf,
  // Future engines can be added here cleanly:
  // mlkitOcr,
}

@JsonSerializable()
class TranscribePagePayload {
  const TranscribePagePayload({
    required this.docId,
    required this.groupId,
    required this.documentName,
    required this.imageRelativePath,
    this.engineId = TranscriptionEngineId.qwenGguf,
  });

  final String docId;
  final String groupId;
  final String documentName;
  final String imageRelativePath;

  @JsonKey(unknownEnumValue: TranscriptionEngineId.qwenGguf)
  final TranscriptionEngineId engineId;

  factory TranscribePagePayload.fromJson(Map<String, dynamic> json) =>
      _$TranscribePagePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$TranscribePagePayloadToJson(this);

  String toJsonString() => jsonEncode(toJson());

  factory TranscribePagePayload.fromJsonString(String raw) =>
      TranscribePagePayload.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
