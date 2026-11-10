import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/routes/docs_router.dart';
import 'package:my_reviewer/src/widgets/docs_screen/docs_grid_view.dart';
import 'package:my_reviewer/src/widgets/docs_screen/docs_selection_app_bar.dart';
import 'package:provider/provider.dart';

class DocsScreen extends StatelessWidget {
  const DocsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DocsController>(
      create: (_) => getIt<DocsController>(),
      child: const _DocsScreenBody(),
    );
  }
}

class _DocsScreenBody extends StatefulWidget {
  const _DocsScreenBody();

  @override
  State<_DocsScreenBody> createState() => _DocsScreenBodyState();
}

class _DocsScreenBodyState extends State<_DocsScreenBody> {
  late final Stream<List<ScannedDocumentGroupModel>> _groupsStream;

  @override
  void initState() {
    super.initState();
    // Cache the stream reference ONCE so StreamBuilder never re-subscribes or resets
    _groupsStream = context.read<DocsController>().watchScannedDocumentGroups();
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionActive = context.select<DocsController, bool>(
      (c) => c.selectionMode.isActive,
    );
    // TickerMode is true when this tab is active/visible, and false when hidden offstage in IndexedStack
    final isTabVisible = TickerMode.valuesOf(context).enabled;

    // Only intercept pop events when selection mode is active AND this tab is currently visible
    final shouldInterceptPop = isSelectionActive && isTabVisible;
    return PopScope(
      canPop: !shouldInterceptPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && shouldInterceptPop) {
          context.read<DocsController>().exitSelectionMode();
        }
      },
      child: StreamBuilder<List<ScannedDocumentGroupModel>>(
        stream: _groupsStream,
        builder: (context, snapshot) {
          final groups = snapshot.data ?? [];

          return Scaffold(
            appBar: DocsSelectionAppBar(groups: groups),
            floatingActionButton: const _DocsFab(),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DocsGridView(snapshot: snapshot, groups: groups),
            ),
          );
        },
      ),
    );
  }
}

/// Isolated FAB widget so floating button updates do not rebuild the body or grid
class _DocsFab extends StatelessWidget {
  const _DocsFab();

  @override
  Widget build(BuildContext context) {
    final isSelectionActive = context.select<DocsController, bool>(
      (c) => c.selectionMode.isActive,
    );

    if (isSelectionActive) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => DocsScanRoute().push(context),
      tooltip: t.docs.main.title,
      icon: const Icon(Icons.camera_alt),
      label: Text(t.docs.scan.title),
    );
  }
}
