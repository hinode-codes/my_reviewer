import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs_scan_controller.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/models/docs_scan_state.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/widgets/confirmation_dialog.dart';
import 'package:my_reviewer/src/widgets/docs_scan_screen/docs_scan_empty_view.dart';
import 'package:my_reviewer/src/widgets/save_progress_dialog.dart';
import 'package:my_reviewer/src/widgets/docs_scan_screen/docs_scan_preview_screen.dart';
import 'package:provider/provider.dart';

class DocsScanScreen extends StatelessWidget {
  const DocsScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DocsScanController>(
      create: (_) => getIt<DocsScanController>(),
      child: const _DocsScanContent(),
    );
  }
}

class _DocsScanContent extends StatefulWidget {
  const _DocsScanContent();

  @override
  State<_DocsScanContent> createState() => _DocsScanContentState();
}

class _DocsScanContentState extends State<_DocsScanContent> {
  @override
  void initState() {
    super.initState();

    // The controller notifies as soon as the scan starts, which is not
    // allowed while the tree is still building, so wait for the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startInitialScan();
      }
    });
  }

  Future<void> _startInitialScan() async {
    final outcome = await context.read<DocsScanController>().startInitialScan();

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case DocsScanOutcome.cancelled || DocsScanOutcome.failed:
        // if the scanner was cancelled in a different
        // orientation, Android would require the Flutter
        // activity to be recreated, which would cause the
        // DocsScanScreen to be rebuilt.
        // So, before popping, we add a post-frame callback to
        // ensure that the current frame is rendered.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          final navigator = Navigator.of(context);

          if (navigator.canPop()) {
            navigator.pop();
          }
        });
      case DocsScanOutcome.captured || DocsScanOutcome.skipped:
        break;
    }
  }

  /// Runs when a back gesture or button is blocked because scans are staged.
  /// Offers to discard, save, or stay.
  Future<void> _onExitRequested() async {
    final strings = t.docs.scan.discard;

    final choice = await ConfirmationDialog.show(
      context,
      title: strings.title,
      message: strings.message,
      confirmLabel: strings.confirm, // Discard
      cancelLabel: strings.cancel, // Keep editing
      tertiaryLabel: strings.save, // Save
      tone: ConfirmTone.destructive,
    );

    if (!mounted) {
      return;
    }

    switch (choice) {
      case ConfirmChoice.confirm:
        _pop();
      case ConfirmChoice.tertiary:
        await _saveThenExit();
      case ConfirmChoice.cancel:
      case null:
        break;
    }
  }

  /// Only reached with pages staged (the exit guard gates it), so the save
  /// always has something to do. Shows the progress dialog bound to the
  /// controller, then leaves on success or reports the failure.
  Future<void> _saveThenExit() async {
    final controller = context.read<DocsScanController>();
    final status = await SaveProgressDialog.run(
      context,
      controller: controller,
    );

    if (mounted && status == SaveStatus.saved) {
      _pop();
    }
  }

  void _pop() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final exitGuard = context.select(
      (DocsScanController controller) => controller.exitGuard,
    );
    final view = context.select(
      (DocsScanController controller) => controller.view,
    );

    return PopScope<void>(
      canPop: exitGuard == DocsScanExitGuard.allowed,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }

        _onExitRequested();
      },
      child: switch (view) {
        DocsScanView.loading => const _DocsScanLoadingView(),
        DocsScanView.empty => DocsScanEmptyView(
          onRetry: () {
            context.read<DocsScanController>().scanMorePages();
          },
        ),
        DocsScanView.preview => const DocsScanPreviewScreen(),
      },
    );
  }
}

class _DocsScanLoadingView extends StatelessWidget {
  const _DocsScanLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
