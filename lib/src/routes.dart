import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/docs_main_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/group_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/group_edit_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_transcription.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/page_viewer_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/screens/docs_main_screen.dart';
import 'package:my_reviewer/src/features/scanned_documents/screens/group_edit_screen.dart';
import 'package:my_reviewer/src/features/scanned_documents/screens/group_screen.dart';
import 'package:my_reviewer/src/features/scanned_documents/screens/page_image_screen.dart';
import 'package:my_reviewer/src/features/scanned_documents/screens/page_transcription_screen.dart';
import 'package:my_reviewer/src/features/scanned_documents/screens/page_viewer_screen.dart';
import 'package:my_reviewer/src/features/scanned_documents/screens/scan_preview_screen.dart';
import 'package:my_reviewer/src/features/settings/controllers/settings_controller.dart';
import 'package:my_reviewer/src/features/settings/screens/settings_screen.dart';
import 'package:my_reviewer/src/locators/main_locator.dart';
import 'package:my_reviewer/src/shared/controllers/ai_model_selector_controller.dart';
import 'package:provider/provider.dart';

import 'main_page_screen.dart';

part "routes.g.dart";

final rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "Root Navigator",
);

final pageViewerNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "Page Viewer Navigator",
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
                TypedShellRoute<PageViewerShellRouteData>(
                  routes: <TypedRoute<RouteData>>[
                    TypedGoRoute<DocsPageViewerRouteData>(path: ":docId"),
                    TypedGoRoute<DocsPageViewerTranscriptionRouteData>(
                      path: ":docId/transcription",
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
    return ChangeNotifierProvider<DocsMainController>(
      create: (_) => getIt<DocsMainController>(),
      child: DocsMainScreen(query: query),
    );
  }
}

class DocsScanPreviewRouteData extends GoRouteData
    with $DocsScanPreviewRouteData {
  const DocsScanPreviewRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider<ScanController>(
      create: (_) => getIt<ScanController>(),
      child: const ScanPreviewScreen(),
    );
  }
}

class DocsGroupRouteData extends GoRouteData with $DocsGroupRouteData {
  const DocsGroupRouteData({required this.groupId, this.$extra});

  final String groupId;
  final List<ScannedDocumentModel>? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider<GroupController>(
      create: (_) => getIt<GroupController>(
        param1: (groupId: groupId, initialDocuments: $extra),
      ),
      child: const GroupScreen(),
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
        final controller = getIt<GroupEditController>(
          param1: groupId,
          param2: $extra,
        );

        unawaited(controller.initialize());

        return controller;
      },
      child: const GroupEditScreen(),
    );
  }
}

class PageViewerShellRouteData extends ShellRouteData {
  const PageViewerShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = pageViewerNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    final groupId = state.pathParameters['groupId']!;
    final docId = state.pathParameters['docId']!;
    final extra = state.extra;
    final initialDocuments = extra is List<ScannedDocumentModel> ? extra : null;

    return ChangeNotifierProvider<PageViewerController>(
      create: (_) {
        final controller = getIt<PageViewerController>(
          param1: (
            groupId: groupId,
            docId: docId,
            initialDocuments: initialDocuments,
          ),
        );

        unawaited(controller.initialize());

        return controller;
      },
      child: PageViewerScreen(navigator: navigator),
    );
  }
}

class DocsPageViewerRouteData extends GoRouteData
    with $DocsPageViewerRouteData {
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
    return const DocsPageImageScreen();
  }
}

class DocsPageViewerTranscriptionRouteData extends GoRouteData
    with $DocsPageViewerTranscriptionRouteData {
  const DocsPageViewerTranscriptionRouteData({
    required this.groupId,
    required this.docId,
    this.$extra,
  });

  final String groupId;
  final String docId;
  final List<ScannedDocumentModel>? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChangeNotifierProvider<PageTranscriptionController>(
      create: (_) => getIt<PageTranscriptionController>(param1: groupId),
      child: const PageTranscriptionScreen(),
    );
  }
}

class LearnShellBranchData extends StatefulShellBranchData {
  const LearnShellBranchData();
}

class LearnRouteData extends GoRouteData with $LearnRouteData {
  const LearnRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Center(child: Text("Learn"));
  }
}

class SettingsShellBranchData extends StatefulShellBranchData {
  const SettingsShellBranchData();
}

class SettingsRouteData extends GoRouteData with $SettingsRouteData {
  const SettingsRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final settingsController = getIt<SettingsController>();
    final modelSelectorController = getIt<AiModelSelectorController>();

    unawaited(settingsController.initialize());
    unawaited(modelSelectorController.initialize());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
        ),
        ChangeNotifierProvider<AiModelSelectorController>.value(
          value: modelSelectorController,
        ),
      ],
      child: const SettingsScreen(),
    );
  }
}
