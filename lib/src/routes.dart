import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs/docs_controller.dart';
import 'package:my_reviewer/src/controllers/docs/docs_scan_controller.dart';
import 'package:my_reviewer/src/controllers/docs/group_controller.dart';
import 'package:my_reviewer/src/controllers/docs/group_edit_controller.dart';
import 'package:my_reviewer/src/controllers/docs/page_viewer_controller.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/screens/docs/docs_group_edit_screen.dart';
import 'package:my_reviewer/src/screens/docs/docs_group_screen.dart';
import 'package:my_reviewer/src/screens/docs/docs_page_viewer_screen.dart';
import 'package:my_reviewer/src/screens/docs/docs_scan_preview_screen.dart';
import 'package:my_reviewer/src/screens/docs/docs_screen.dart';
import 'package:my_reviewer/src/screens/main_page_screen.dart';
import 'package:provider/provider.dart';

part "routes.g.dart";

final rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "Root Navigator",
);

@TypedStatefulShellRoute<MainShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<DocsShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<DocsRouteData>(
          path: "/docs",
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<DocsScanPreviewRouteData>(path: "scan"),
            TypedGoRoute<DocsGroupRouteData>(
              path: "groups/:groupId",
              routes: <TypedRoute<RouteData>>[
                TypedGoRoute<DocsGroupEditRouteData>(path: "edit"),
                TypedGoRoute<DocsPageViewerRouteData>(
                  path: ":docId",
                  routes: <TypedRoute<RouteData>>[
                    TypedGoRoute<DocsPageViewerTranscriptionRouteData>(
                      path: "transcription",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    TypedStatefulShellBranch<LearnShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<LearnRouteData>(path: "/learn"),
      ],
    ),

    TypedStatefulShellBranch<SettingsShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SettingsRouteData>(path: "/settings"),
      ],
    ),
  ],
)
class MainShellRouteData extends StatefulShellRouteData {
  const MainShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainPageScreen(navigationShell: navigationShell);
  }
}

class DocsShellBranchData extends StatefulShellBranchData {
  const DocsShellBranchData();

  static final $observers = <NavigatorObserver>[];
}

class DocsRouteData extends GoRouteData with $DocsRouteData {
  const DocsRouteData({this.query});

  final String? query;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider<DocsController>(
      create: (_) => getIt<DocsController>(),
      child: DocsScreen(query: query),
    );
  }
}

class DocsScanPreviewRouteData extends GoRouteData
    with $DocsScanPreviewRouteData {
  const DocsScanPreviewRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider<DocsScanController>(
      create: (_) => getIt<DocsScanController>(),
      child: const DocsScanPreviewScreen(),
    );
  }
}

class DocsGroupRouteData extends GoRouteData with $DocsGroupRouteData {
  const DocsGroupRouteData({required this.groupId, this.$extra});

  final String groupId;
  final List<ScannedDocumentModel>? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider<DocsGroupController>(
      create: (_) => getIt<DocsGroupController>(
        param1: (docId: groupId, initialDocuments: $extra),
      ),
      child: const DocsGroupScreen(),
    );
  }
}

class DocsGroupEditRouteData extends GoRouteData with $DocsGroupEditRouteData {
  const DocsGroupEditRouteData({required this.groupId, this.$extra});

  final String groupId;
  final ScannedDocumentGroupModel? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider<GroupEditController>(
      create: (_) {
        final thing = getIt<GroupEditController>(
          param1: groupId,
          param2: $extra,
        );

        unawaited(thing.initialize());

        return thing;
      },
      child: const DocsGroupEditScreen(),
    );
  }
}

class DocsPageViewerRouteData extends GoRouteData with $DocsPageViewerRouteData {
  const DocsPageViewerRouteData({
    required this.groupId,
    required this.docId,
    this.$extra,
  });

  final String groupId;

  /// The page the viewer opens at. Swiping moves the viewer on without
  /// changing this, so the page on screen comes from the controller.
  final String docId;

  /// The group's pages, when opened from the grid. Null on a deep link,
  /// in which case the controller fetches them.
  final List<ScannedDocumentModel>? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider<DocsPageViewerController>(
      create: (_) {
        final controller = getIt<DocsPageViewerController>(
          param1: (groupId: groupId, docId: docId, initialDocuments: $extra),
        );

        unawaited(controller.initialize());

        return controller;
      },
      child: const DocsPageViewerScreen(),
    );
  }
}

class DocsPageViewerTranscriptionRouteData extends GoRouteData
    with $DocsPageViewerTranscriptionRouteData {
  const DocsPageViewerTranscriptionRouteData({
    required this.groupId,
    required this.docId,
  });

  final String groupId;
  final String docId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // TODO: implement build
    return super.build(context, state);
  }
}

class LearnShellBranchData extends StatefulShellBranchData {
  const LearnShellBranchData();
}

class LearnRouteData extends GoRouteData with $LearnRouteData {
  const LearnRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Center(child: Text("Learn"));
  }
}

class SettingsShellBranchData extends StatefulShellBranchData {
  const SettingsShellBranchData();
}

class SettingsRouteData extends GoRouteData with $SettingsRouteData {
  const SettingsRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Center(child: Text("Settings"));
  }
}