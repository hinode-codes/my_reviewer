import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/controllers/ai_model_selector_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/models/confirmation.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_model_provisioner.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/confirmation_dialog.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/task_dialog.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class AiModelSelectorSection extends AbstractSettingsSection {
  const AiModelSelectorSection({
    super.key,
    required this.taskKind,
    this.extraTiles = const [],
  });

  final TaskKind taskKind;
  final List<AbstractSettingsTile> extraTiles;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AiModelSelectorController>();
    final selected = controller.selectedModel;
    final status = controller.selectedStatus;
    final m = t.settings.main.model;

    return SettingsSection(
      title: Text(m.title),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.memory_outlined),
          title: Text(m.title),
          description: Text(
            status.phase == AiModelInstallPhase.ready
                ? '${selected.subtitle} • ${m.status.ready}'
                : selected.subtitle,
          ),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedModelId,
              items: [
                for (final model in controller.models)
                  DropdownMenuItem<String>(
                    value: model.id,
                    child: _ModelDropdownOption(
                      spec: model,
                      status: controller.statusFor(model),
                    ),
                  ),
              ],
              onChanged: (nextId) async {
                if (nextId == null) {
                  return;
                }

                final switchedImmediately = await controller.selectModel(
                  nextId,
                );

                if (switchedImmediately || !context.mounted) {
                  return;
                }

                await _confirmAndProvision(context, controller);
              },
            ),
          ),
        ),
        if (status.phase.needsRecovery ||
            status.phase == AiModelInstallPhase.notInstalled)
          CustomSettingsTile(
            child: _ModelStatusBanner(
              status: status,
              onPrimaryAction: () => _confirmAndProvision(context, controller),
              onDiscardAction: status.phase == AiModelInstallPhase.notInstalled
                  ? null
                  : () => _confirmAndDiscard(context, controller),
              onSizeInfoAction: () => _showSizeInfoDialog(context, selected),
            ),
          ),
        ...extraTiles,
      ],
    );
  }

  Future<void> _confirmAndProvision(
    BuildContext context,
    AiModelSelectorController controller,
  ) async {
    final status = controller.selectedStatus;
    final m = t.settings.main.model;

    final (title, message, confirmLabel) = switch (status.phase) {
      AiModelInstallPhase.notInstalled => (
        m.dialogs.required.title,
        '${m.dialogs.required.message}\n\n'
            '${m.size.label(size: _formatSize(status.spec.totalBytes))}',
        m.actions.download,
      ),
      AiModelInstallPhase.partialDownload => (
        m.alerts.partial.title,
        m.alerts.partial.message,
        m.actions.resume,
      ),
      AiModelInstallPhase.downloadedUnverified => (
        m.alerts.unverified.title,
        m.alerts.unverified.message,
        m.actions.completeSetup,
      ),
      AiModelInstallPhase.verifiedUnintegrated => (
        m.alerts.unintegrated.title,
        m.alerts.unintegrated.message,
        m.actions.completeSetup,
      ),
      AiModelInstallPhase.failed => (
        m.alerts.failed.title,
        status.errorMessage ?? m.alerts.failed.message,
        m.actions.retry,
      ),
      AiModelInstallPhase.ready => ('', '', ''),
    };

    final choice = await ConfirmationDialog.show(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: m.actions.cancel,
    );

    if (choice != ConfirmChoice.confirm || !context.mounted) {
      return;
    }

    await TaskDialog.run(
      context,
      task: controller.provisionTask,
      kind: taskKind,
      messages: TaskDialogMessages(
        preparing: m.status.preparing,
        processing: (current, total) => switch (controller.provisionPhase) {
          ProvisionPhase.downloading => m.status.downloading(progress: current),
          ProvisionPhase.verifying => m.status.verifying,
          ProvisionPhase.integrating => m.status.integrating,
        },
        finishing: m.status.finishing,
        succeeded: m.status.done,
        failed: m.status.failed,
      ),
    );
  }

  Future<void> _confirmAndDiscard(
    BuildContext context,
    AiModelSelectorController controller,
  ) async {
    final spec = controller.selectedModel;
    final m = t.settings.main.model;

    final choice = await ConfirmationDialog.show(
      context,
      title: m.dialogs.discard.title,
      message: m.dialogs.discard.message(name: spec.displayName),
      confirmLabel: m.actions.discard,
      cancelLabel: m.actions.cancel,
      tone: ConfirmTone.destructive,
    );

    if (choice == ConfirmChoice.confirm) {
      await controller.discardIncomplete();
    }
  }

  Future<void> _showSizeInfoDialog(
    BuildContext context,
    AiModelSpec spec,
  ) async {
    final m = t.settings.main.model;
    final totalFormatted = _formatSize(spec.totalBytes);

    await ConfirmationDialog.show(
      context,
      title: m.dialogs.size.title,
      message:
          '${m.dialogs.size.total(size: totalFormatted)}\n'
          '${m.dialogs.size.fileCount(n: spec.artifacts.length)}',
      confirmLabel: t.common.actions.done,
      cancelLabel: m.actions.cancel,
    );
  }
}

class _ModelDropdownOption extends StatelessWidget {
  const _ModelDropdownOption({required this.spec, required this.status});

  final AiModelSpec spec;
  final AiModelStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final icon = switch (status.phase) {
      AiModelInstallPhase.ready => Icon(
        Icons.check_circle_outline,
        size: 16,
        color: colorScheme.primary,
      ),
      AiModelInstallPhase.partialDownload ||
      AiModelInstallPhase.downloadedUnverified ||
      AiModelInstallPhase.verifiedUnintegrated => Icon(
        Icons.pending_outlined,
        size: 16,
        color: colorScheme.tertiary,
      ),
      AiModelInstallPhase.failed => Icon(
        Icons.error_outline,
        size: 16,
        color: colorScheme.error,
      ),
      AiModelInstallPhase.notInstalled => Icon(
        Icons.cloud_download_outlined,
        size: 16,
        color: colorScheme.onSurfaceVariant,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [icon, const SizedBox(width: 8), Text(spec.displayName)],
    );
  }
}

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
    final colorScheme = theme.colorScheme;
    final m = t.settings.main.model;
    final isError = status.phase == AiModelInstallPhase.failed;

    final backgroundColor = isError
        ? colorScheme.errorContainer.withValues(alpha: 0.45)
        : colorScheme.secondaryContainer.withValues(alpha: 0.55);
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;

    final (icon, headline, body, actionLabel) = switch (status.phase) {
      AiModelInstallPhase.notInstalled => (
        Icons.download_for_offline_outlined,
        m.alerts.missing.title,
        m.alerts.missing.message,
        m.actions.download,
      ),
      AiModelInstallPhase.partialDownload => (
        Icons.downloading_outlined,
        m.alerts.partial.title,
        m.alerts.partial.message,
        m.actions.resume,
      ),
      AiModelInstallPhase.downloadedUnverified => (
        Icons.verified_user_outlined,
        m.alerts.unverified.title,
        m.alerts.unverified.message,
        m.actions.completeSetup,
      ),
      AiModelInstallPhase.verifiedUnintegrated => (
        Icons.extension_outlined,
        m.alerts.unintegrated.title,
        m.alerts.unintegrated.message,
        m.actions.completeSetup,
      ),
      AiModelInstallPhase.failed => (
        Icons.warning_amber_rounded,
        m.alerts.failed.title,
        status.errorMessage ?? m.alerts.failed.message,
        m.actions.retry,
      ),
      AiModelInstallPhase.ready => (Icons.check_circle_outline, '', '', ''),
    };

    final sizeText = status.spec.totalBytes > 0
        ? m.size.label(size: _formatSize(status.spec.totalBytes))
        : m.size.unavailable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: foregroundColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      headline,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    sizeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foregroundColor.withValues(alpha: 0.85),
                    ),
                  ),
                  if (onSizeInfoAction != null) ...[
                    const SizedBox(width: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onSizeInfoAction,
                      child: Text(m.size.actions.moreInfo),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onDiscardAction != null) ...[
                    TextButton(
                      onPressed: onDiscardAction,
                      child: Text(m.actions.discard),
                    ),
                    const SizedBox(width: 8),
                  ],
                  FilledButton.tonal(
                    onPressed: onPrimaryAction,
                    child: Text(actionLabel),
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

String _formatSize(int bytes) {
  if (bytes <= 0) {
    return '0 MB';
  }
  final mb = bytes / (1024 * 1024);
  if (mb >= 1024) {
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }
  return '${mb.toStringAsFixed(0)} MB';
}
