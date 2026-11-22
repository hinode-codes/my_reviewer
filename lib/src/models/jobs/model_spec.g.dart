// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelFileSpec _$ModelFileSpecFromJson(Map<String, dynamic> json) =>
    ModelFileSpec(
      id: json['id'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      sha256: json['sha256'] as String,
      role: $enumDecode(_$ModelFileRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$ModelFileSpecToJson(ModelFileSpec instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'filename': instance.filename,
      'sizeBytes': instance.sizeBytes,
      'sha256': instance.sha256,
      'role': _$ModelFileRoleEnumMap[instance.role]!,
    };

const _$ModelFileRoleEnumMap = {
  ModelFileRole.model: 'model',
  ModelFileRole.mmproj: 'mmproj',
  ModelFileRole.adapter: 'adapter',
};

ModelSpec _$ModelSpecFromJson(Map<String, dynamic> json) => ModelSpec(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  reason: json['reason'] as String,
  files: (json['files'] as List<dynamic>)
      .map((e) => ModelFileSpec.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ModelSpecToJson(ModelSpec instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'reason': instance.reason,
  'files': instance.files.map((e) => e.toJson()).toList(),
};
