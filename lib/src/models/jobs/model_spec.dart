import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'model_spec.g.dart';

@JsonEnum()
enum ModelFileRole { model, mmproj, adapter }

@JsonSerializable()
class ModelFileSpec {
  const ModelFileSpec({
    required this.id,
    required this.url,
    required this.filename,
    required this.sizeBytes,
    required this.sha256,
    required this.role,
  });

  final String id;
  final String url;
  final String filename;
  final int sizeBytes;
  final String sha256;
  final ModelFileRole role;

  factory ModelFileSpec.fromJson(Map<String, dynamic> json) =>
      _$ModelFileSpecFromJson(json);

  Map<String, dynamic> toJson() => _$ModelFileSpecToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ModelSpec {
  const ModelSpec({
    required this.id,
    required this.displayName,
    required this.reason,
    required this.files,
  });

  final String id;
  final String displayName;
  final String reason;
  final List<ModelFileSpec> files;

  factory ModelSpec.fromJson(Map<String, dynamic> json) =>
      _$ModelSpecFromJson(json);

  Map<String, dynamic> toJson() => _$ModelSpecToJson(this);

  String toPayload() => jsonEncode(toJson());

  factory ModelSpec.fromPayload(String payload) =>
      ModelSpec.fromJson(jsonDecode(payload) as Map<String, dynamic>);
}
