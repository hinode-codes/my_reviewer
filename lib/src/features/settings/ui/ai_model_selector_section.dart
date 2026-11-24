import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/controllers/ai_model_selector_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/models/confirmation.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/confirmation_dialog.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/info_dialog.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/task_dialog.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

/// Settings section allowing users to choose an on-device AI transcription
/// model and manage its download, verification, integration, or cleanup.
class AiModelSelectorSection extends AbstractSettingsSection {
  const AiModelSelectorSection({super.key, required this.taskKind});

  /// Execution context passed to [TaskDialog.run] during model provisioning.
  final TaskKind taskKind;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AiModelSelectorController>();
    final selected = controller.selectedModel;
    final status = controller.selectedStatus;
    final m = t.settings.main.model;
    final isNotInstalled = status.phase == AiModelInstallPhase.notInstalled;

    return SettingsSection(
      title: Text(m.title),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.memory_outlined),
          title: Text(m.title),
          titleDescription: Text(
            m.subtitle(context: status.phase, subtitle: selected.subtitle),
          ),
          value: Text(selected.displayName),
          onPressed: (ctx) => _openModelPicker(ctx, controller),
        ),
        if (status.phase.needsRecovery || isNotInstalled)
          CustomSettingsTile(
            child: _ModelStatusBanner(
              status: status,
              onPrimaryAction: () => _confirmAndProvision(context, controller),
              onDiscardAction: isNotInstalled
                  ? null
                  : () => _confirmAndDiscard(context, controller),
              onSizeInfoAction: () => _showSizeInfoDialog(context, selected),
            ),
          ),
      ],
    );
  }

  /// Opens a modal bottom sheet listing all registered [AiModelSpec] options.
  ///
  /// Switches immediately if the chosen model is already ready; otherwise,
  /// prompts the user to download or complete setup.
  Future<void> _openModelPicker(
    BuildContext context,
    AiModelSelectorController controller,
  ) async {
    final nextId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _ModelPickerSheet(controller: controller),
    );

    if (nextId == null || !context.mounted) return;

    final switchedImmediately = await controller.selectModel(nextId);
    if (switchedImmediately || !context.mounted) return;

    await _confirmAndProvision(context, controller);
  }

  /// Confirms model download or recovery with the user and runs provisioning
  /// inside a [TaskDialog].
  Future<void> _confirmAndProvision(
    BuildContext context,
    AiModelSelectorController controller,
  ) async {
    final status = controller.selectedStatus;
    final m = t.settings.main.model;
    final setup = m.dialogs.setup;

    final choice = await ConfirmationDialog.show(
      context,
      title: setup.title(context: status.phase),
      message: setup.message(
        context: status.phase,
        size: formatByteSize(status.spec.totalBytes, minUnitIndex: 2),
        error: status.errorMessage ?? t.common.status.failed,
      ),
      confirmLabel: setup.confirmLabel(context: status.phase),
      cancelLabel: m.actions.cancel,
    );

    if (choice != ConfirmChoice.confirm || !context.mounted) return;

    await TaskDialog.run(
      context,
      task: controller.provisionTask,
      kind: taskKind,
      messages: TaskDialogMessages(
        preparing: m.status.preparing,
        processing: (current, _) => m.status.processing(
          context: controller.provisionPhase,
          progress: current,
        ),
        finishing: m.status.finishing,
        succeeded: m.status.done,
        failed: m.status.failed,
      ),
    );
  }

  /// Confirms and deletes partial or corrupted files for the selected model.
  Future<void> _confirmAndDiscard(
    BuildContext context,
    AiModelSelectorController controller,
  ) async {
    final m = t.settings.main.model;

    final choice = await ConfirmationDialog.show(
      context,
      title: m.dialogs.discard.title,
      message: m.dialogs.discard.message(
        name: controller.selectedModel.displayName,
      ),
      confirmLabel: m.actions.discard,
      cancelLabel: m.actions.cancel,
      tone: ConfirmTone.destructive,
    );

    if (choice == ConfirmChoice.confirm) {
      await controller.discardIncomplete();
    }
  }

  /// Displays total download size and artifact count for [spec].
  Future<void> _showSizeInfoDialog(
    BuildContext context,
    AiModelSpec spec,
  ) async {
    final m = t.settings.main.model;

    await InfoDialog.show(
      context,
      title: m.dialogs.size.title,
      message: m.dialogs.size.message(
        size: formatByteSize(spec.totalBytes, minUnitIndex: 2),
        n: spec.artifacts.length,
      ),
      closeLabel: t.common.actions.done,
    );
  }
}

/// Bottom-sheet list allowing selection among available [AiModelSpec] entries.
class _ModelPickerSheet extends StatelessWidget {
  const _ModelPickerSheet({required this.controller});

  final AiModelSelectorController controller;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.models.length,
        itemBuilder: (sheetContext, index) {
          final model = controller.models[index];
          final isSelected = model.id == controller.selectedModelId;

          return ListTile(
            leading: _ModelStatusIcon(phase: controller.statusFor(model).phase),
            title: Text(model.displayName),
            subtitle: Text(model.subtitle),
            trailing: isSelected
                ? Icon(Icons.check, color: primaryColor)
                : null,
            onTap: () => Navigator.of(sheetContext).pop(model.id),
          );
        },
      ),
    );
  }
}

/// Leading icon reflecting a model's [AiModelInstallPhase] in the picker sheet.
class _ModelStatusIcon extends StatelessWidget {
  const _ModelStatusIcon({required this.phase});

  final AiModelInstallPhase phase;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final (icon, color) = switch (phase) {
      AiModelInstallPhase.ready => (Icons.check_circle_outline, colors.primary),
      AiModelInstallPhase.partialDownload ||
      AiModelInstallPhase.downloadedUnverified ||
      AiModelInstallPhase.verifiedUnintegrated => (
        Icons.pending_outlined,
        colors.tertiary,
      ),
      AiModelInstallPhase.failed => (Icons.error_outline, colors.error),
      AiModelInstallPhase.notInstalled => (
        Icons.cloud_download_outlined,
        colors.onSurfaceVariant,
      ),
    };

    return Icon(icon, color: color);
  }
}

/// Inline status card displaying setup prompts, recovery actions, and size info
/// whenever the selected model is not yet [AiModelInstallPhase.ready].
class _ModelStatusBanner extends StatelessWidget {
  const _ModelStatusBanner({
    required this.status,
    required this.onPrimaryAction,
    this.onDiscardAction,
    this.onSizeInfoAction,
  });

  final AiModelStatus status;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onDiscardAction;
  final VoidCallback? onSizeInfoAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final m = t.settings.main.model;
    final banner = m.alerts.banner;
    final isError = status.phase == AiModelInstallPhase.failed;

    final (bgColor, fgColor) = isError
        ? (
            colors.errorContainer.withValues(alpha: 0.45),
            colors.onErrorContainer,
          )
        : (
            colors.secondaryContainer.withValues(alpha: 0.55),
            colors.onSecondaryContainer,
          );

    final icon = switch (status.phase) {
      AiModelInstallPhase.notInstalled => Icons.download_for_offline_outlined,
      AiModelInstallPhase.partialDownload => Icons.downloading_outlined,
      AiModelInstallPhase.downloadedUnverified => Icons.verified_user_outlined,
      AiModelInstallPhase.verifiedUnintegrated => Icons.extension_outlined,
      AiModelInstallPhase.failed => Icons.warning_amber_rounded,
      AiModelInstallPhase.ready => Icons.check_circle_outline,
    };

    final totalBytes = status.spec.totalBytes;
    final sizeText = totalBytes > 0
        ? m.size.label(size: formatByteSize(totalBytes, minUnitIndex: 2))
        : m.size.unavailable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: AppSizes.icon, color: fgColor),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      banner.title(context: status.phase),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                banner.message(
                  context: status.phase,
                  error: status.errorMessage ?? m.alerts.failed.message,
                ),
                style: theme.textTheme.bodySmall?.copyWith(color: fgColor),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text(
                    sizeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fgColor.withValues(alpha: AppOpacity.scrim),
                    ),
                  ),
                  if (onSizeInfoAction != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onSizeInfoAction,
                      child: Text(m.size.actions.moreInfo),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onDiscardAction != null) ...[
                    TextButton(
                      onPressed: onDiscardAction,
                      child: Text(m.actions.discard),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  FilledButton.tonal(
                    onPressed: onPrimaryAction,
                    child: Text(banner.actionLabel(context: status.phase)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
