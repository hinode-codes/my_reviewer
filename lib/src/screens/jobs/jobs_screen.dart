import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/jobs/jobs_controller.dart';
import 'package:my_reviewer/src/db/models/jobs_model.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:provider/provider.dart';

const int _bytesPerMegabyte = 1024 * 1024;
const int _secondsPerMinute = 60;
const int _secondsPerHour = 3600;

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<JobsController>();
    final jobs = controller.jobs;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.jobs.title),
        actions: [
          if (controller.hasFinishedJobs)
            IconButton(
              tooltip: t.jobs.actions.clearFinished,
              icon: const Icon(Icons.cleaning_services_outlined),
              onPressed: () => unawaited(controller.clearFinished()),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: SegmentedButton<JobFilter>(
              segments: [
                ButtonSegment(
                  value: JobFilter.all,
                  label: Text(t.jobs.filters.all),
                ),
                ButtonSegment(
                  value: JobFilter.active,
                  label: Text(
                    t.jobs.filters.active(count: controller.activeCount),
                  ),
                ),
                ButtonSegment(
                  value: JobFilter.failed,
                  label: Text(t.jobs.filters.failed),
                ),
              ],
              selected: {controller.filter},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  controller.setFilter(selection.first);
                }
              },
            ),
          ),
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : jobs.isEmpty
                ? Center(
                    child: Text(
                      t.jobs.empty.all,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: jobs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _DetailedJobCard(
                      item: jobs[index],
                      controller: controller,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailedJobCard extends StatelessWidget {
  const _DetailedJobCard({required this.item, required this.controller});

  final JobItemViewModel item;
  final JobsController controller;

  bool get _isVerifyingIntegrity =>
      item.isModelDownload &&
      item.isActive &&
      item.reason == 'Verifying files integrity...';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metricsText = _formatMetrics(item);

    final (statusLabel, statusColor) = switch (item.status) {
      JobStatus.queued => (t.jobs.status.queued, colorScheme.secondary),
      JobStatus.running => (t.jobs.status.running, colorScheme.primary),
      JobStatus.succeeded => (t.jobs.status.succeeded, Colors.green),
      JobStatus.dead => (t.jobs.status.failed, colorScheme.error),
      JobStatus.cancelled => (
        t.jobs.status.cancelled,
        colorScheme.onSurfaceVariant,
      ),
    };

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: (item.groupId != null && item.docId != null)
            ? () {
                DocsPageViewerTranscriptionRouteData(
                  groupId: item.groupId!,
                  docId: item.docId!,
                ).go(context);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    item.type == JobType.download
                        ? Icons.downloading_outlined
                        : Icons.document_scanner_outlined,
                    size: AppSizes.icon,
                    color: statusColor,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.reason != null && item.reason!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.reason!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (metricsText != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  metricsText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
              if (item.isActive) ...[
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: _isVerifyingIntegrity
                      ? null
                      : (item.progress > 0 ? item.progress : null),
                ),
              ],
              if (item.status == JobStatus.running &&
                  item.partialOutput != null &&
                  item.partialOutput!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Text(
                    item.partialOutput!.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (item.lastError != null && item.lastError!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.lastError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.canCancel || item.canRetry || item.canDelete) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (item.attempts > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Text(
                          'Attempt ${item.attempts}/${item.maxAttempts}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (item.canCancel)
                      TextButton.icon(
                        onPressed: () =>
                            unawaited(controller.cancelJob(item.id)),
                        icon: const Icon(Icons.stop_circle_outlined, size: 18),
                        label: Text(t.common.buttons.cancel),
                      ),
                    if (item.canRetry)
                      TextButton.icon(
                        onPressed: () =>
                            unawaited(controller.retryJob(item.id)),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(t.common.buttons.retry),
                      ),
                    if (item.canDelete)
                      IconButton(
                        tooltip: t.common.buttons.delete,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () =>
                            unawaited(controller.deleteJob(item.id)),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _formatMetrics(JobItemViewModel item) {
    if (_isVerifyingIntegrity) {
      return null;
    }

    final parts = <String>[];

    if (item.totalBytes > 0) {
      final currentMb = (item.currentBytes / _bytesPerMegabyte).toStringAsFixed(
        1,
      );
      final totalMb = (item.totalBytes / _bytesPerMegabyte).toStringAsFixed(1);
      final pct = ((item.currentBytes / item.totalBytes).clamp(0.0, 1.0) * 100)
          .toStringAsFixed(0);
      parts.add('$currentMb / $totalMb MB ($pct%)');
    }

    final speed = item.bytesPerSecond;
    if (speed != null && speed > 0) {
      final speedMb = (speed / _bytesPerMegabyte).toStringAsFixed(1);
      parts.add('$speedMb MB/s');
    }

    final eta = item.estimatedRemaining;
    if (eta != null && !eta.isNegative && eta.inSeconds > 0) {
      parts.add(_formatDuration(eta));
    }

    return parts.isEmpty ? null : parts.join(' · ');
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    if (totalSeconds < _secondsPerMinute) return '${totalSeconds}s';
    if (totalSeconds < _secondsPerHour) {
      final minutes = totalSeconds ~/ _secondsPerMinute;
      final seconds = totalSeconds % _secondsPerMinute;
      return '${minutes}m ${seconds}s';
    }
    final hours = totalSeconds ~/ _secondsPerHour;
    final minutes = (totalSeconds % _secondsPerHour) ~/ _secondsPerMinute;
    return '${hours}h ${minutes}m';
  }
}
