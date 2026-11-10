import "package:material_ui/material_ui.dart";
import "package:go_router/go_router.dart";
import "package:my_reviewer/src/screens/docs_detail_screen.dart";
import "package:my_reviewer/src/screens/docs_scan_screen.dart";
import "package:my_reviewer/src/screens/docs_screen.dart";

part "docs_router.g.dart";

@TypedGoRoute<DocsRoute>(
  path: "/docs",
  routes: [
    TypedGoRoute<DocsScanRoute>(path: "scan"),
    TypedGoRoute<DocsDetailRoute>(path: ":docId"),
  ],
)
class DocsRoute extends GoRouteData with $DocsRoute {
  const DocsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DocsScreen();
  }
}

class DocsScanRoute extends GoRouteData with $DocsScanRoute {
  const DocsScanRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DocsScanScreen();
  }
}

class DocsDetailRoute extends GoRouteData with $DocsDetailRoute {
  const DocsDetailRoute({required this.docId, required this.docName});

  final String docId;
  final String docName;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DocsDetailScreen(docId: docId, docName: docName);
  }
}
