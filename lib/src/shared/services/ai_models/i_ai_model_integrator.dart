import 'package:my_reviewer/src/shared/models/ai_model.dart';

abstract interface class IAiModelIntegrator {
  bool supports(AiModelSpec spec);

  /// Registers verified local files (`model`, optional `mmproj`, optional `adapter`)
  /// into `flutter_edge_ai` as the active model. Must be idempotent.
  Future<void> integrate(
    AiModelSpec spec,
    Map<AiModelFileRole, String> resolvedPathsByRole,
  );

  /// Unregisters/deletes active runtime registration if needed.
  Future<void> unintegrate(AiModelSpec spec);
}
