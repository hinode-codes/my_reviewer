import 'package:my_reviewer/src/models/jobs/model_spec.dart';

const String _qwenCommitHash = '52d6c8ffea26cc873ac5ad116f8631268d7eb503';
const String _qwenRepoBase =
    'https://huggingface.co/Qwen/Qwen3-VL-2B-Instruct-GGUF/resolve/$_qwenCommitHash';

/// Pinned Qwen3-VL-2B-Instruct base model (Q4_K_M) and multimodal projector
/// (`mmproj` Q8_0) compatible with `assets/models/adapter.gguf`.
const ModelSpec qwenOcrModelSpec = ModelSpec(
  id: 'qwen_ocr_v1',
  displayName: 'Offline OCR Model (Qwen3-VL-2B)',
  reason: 'Downloads the offline vision model so scanned pages can be transcribed privately on your device.',
  files: [
    ModelFileSpec(
      id: 'base_model',
      url: '$_qwenRepoBase/Qwen3VL-2B-Instruct-Q4_K_M.gguf',
      filename: 'Qwen3VL-2B-Instruct-Q4_K_M.gguf',
      sizeBytes: 1191854080, // ~1.11 GB; background_downloader reads Content-Length dynamically
      sha256:
          '089d75c52f4b7ffc56ba998ffc50aae89fcafc755f9e7208aacca281dca6c2ae',
      role: ModelFileRole.model,
    ),
    ModelFileSpec(
      id: 'mmproj',
      url: '$_qwenRepoBase/mmproj-Qwen3VL-2B-Instruct-Q8_0.gguf',
      filename: 'mmproj-Qwen3VL-2B-Instruct-Q8_0.gguf',
      sizeBytes: 466616320, // ~445 MB; background_downloader reads Content-Length dynamically
      sha256:
          'f9a68fabba69c3b81e153367b2c7521030b0fa8bb0de400c9599c8e6725f9c82',
      role: ModelFileRole.mmproj,
    ),
  ],
);
