import 'package:my_reviewer/src/shared/models/ai_model.dart';

class OcrModelCatalog {
  const OcrModelCatalog._();

  static const String _qwenCommitHash =
      '52d6c8ffea26cc873ac5ad116f8631268d7eb503';
  static const String _qwenRepoBase =
      'https://huggingface.co/Qwen/Qwen3-VL-2B-Instruct-GGUF/resolve/$_qwenCommitHash';

  static const String _adapterCommitHash =
      '9480bb73058359f28eac453394d74e3e38712dda';
  static const String _adapterRepoBase =
      'https://huggingface.co/hinode-codes/qwen_adapter_handwriting/resolve/$_adapterCommitHash';

  static const String qwen3Vl2bId = 'qwen_ocr_v1';

  static const List<AiModelSpec> all = [
    AiModelSpec(
      id: qwen3Vl2bId,
      displayName: 'Qwen3-VL 2B (Default)',
      subtitle: 'Offline vision OCR with fine-tuned Markdown adapter',
      capability: AiModelCapability.ocrTranscription,
      requiresAuthToken:
          true, // Set to true only if your adapter repo is Private
      artifacts: [
        AiModelArtifact(
          id: 'base_model',
          role: AiModelFileRole.model,
          fileName: 'Qwen3VL-2B-Instruct-Q4_K_M.gguf',
          downloadUrl: '$_qwenRepoBase/Qwen3VL-2B-Instruct-Q4_K_M.gguf',
          expectedBytes: 1191854080,
          sha256: '089d75c52f4b7ffc56ba998ffc50aae89fcafc755f9e7208aacca281dca6c2ae',
        ),
        AiModelArtifact(
          id: 'mmproj',
          role: AiModelFileRole.mmproj,
          fileName: 'mmproj-Qwen3VL-2B-Instruct-Q8_0.gguf',
          downloadUrl: '$_qwenRepoBase/mmproj-Qwen3VL-2B-Instruct-Q8_0.gguf',
          expectedBytes: 466616320,
          sha256: 'f9a68fabba69c3b81e153367b2c7521030b0fa8bb0de400c9599c8e6725f9c82',
          optional: true,
        ),
        AiModelArtifact(
          id: 'adapter',
          role: AiModelFileRole.adapter,
          fileName: 'adapter.gguf',
          downloadUrl: '$_adapterRepoBase/adapter.gguf',
          expectedBytes: 69757632,
          sha256: '51dba55fdfcf4432c9b6505041dd79e44e0841aa8aef645b751622fb736e11a9',
          optional: true,
        ),
      ],
    ),
  ];
}
