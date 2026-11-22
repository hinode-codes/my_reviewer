import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'ocr_job_payload.g.dart';

@JsonSerializable()
class OcrJobPayload {
  const OcrJobPayload({
    required this.docId,
    required this.groupId,
    required this.relativePath,
    this.ext = 'txt',
  });

  final String docId;
  final String groupId;
  final String relativePath;
  final String ext;

  factory OcrJobPayload.fromJson(Map<String, dynamic> json) =>
      _$OcrJobPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$OcrJobPayloadToJson(this);

  factory OcrJobPayload.fromRawJson(String raw) =>
      OcrJobPayload.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());
}
