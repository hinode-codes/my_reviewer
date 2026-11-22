import 'package:json_annotation/json_annotation.dart';

part "scanned_document_transcription_model.g.dart";

@JsonSerializable()
class ScannedDocumentTranscriptionModel {
  final String id;
  final String docId;
  final String relativePath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String ext;
  final int timeMsToTranscribe;
  final int timeMsToRead;
  final int wordCount;

  const ScannedDocumentTranscriptionModel({
    required this.id,
    required this.docId,
    required this.relativePath,
    required this.createdAt,
    this.updatedAt,
    required this.ext,
    required this.timeMsToTranscribe,
    required this.timeMsToRead,
    required this.wordCount,
  });

  factory ScannedDocumentTranscriptionModel.fromJson(
    Map<String, dynamic> json,
  ) => _$ScannedDocumentTranscriptionModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ScannedDocumentTranscriptionModelToJson(this);

  ScannedDocumentTranscriptionModel copyWith({
    String? id,
    String? docId,
    String? relativePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ext,
    int? timeMsToTranscribe,
    int? timeMsToRead,
    int? wordCount,
  }) {
    return ScannedDocumentTranscriptionModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      relativePath: relativePath ?? this.relativePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ext: ext ?? this.ext,
      timeMsToTranscribe: timeMsToTranscribe ?? this.timeMsToTranscribe,
      timeMsToRead: timeMsToRead ?? this.timeMsToRead,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  ScannedDocumentTranscriptionModel clone() {
    return ScannedDocumentTranscriptionModel(
      id: id,
      docId: docId,
      relativePath: relativePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
      ext: ext,
      timeMsToTranscribe: timeMsToTranscribe,
      timeMsToRead: timeMsToRead,
      wordCount: wordCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedDocumentTranscriptionModel &&
          other.id == id &&
          other.docId == docId &&
          other.relativePath == relativePath &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.ext == ext &&
          other.timeMsToTranscribe == timeMsToTranscribe &&
          other.timeMsToRead == timeMsToRead &&
          other.wordCount == wordCount;

  @override
  int get hashCode => Object.hash(
    id,
    docId,
    relativePath,
    createdAt,
    updatedAt,
    ext,
    timeMsToTranscribe,
    timeMsToRead,
    wordCount,
  );
}
