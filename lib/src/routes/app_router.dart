import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/routes/docs_router.dart' as docs_router;
import 'package:my_reviewer/src/routes/flashcards_router.dart'
    as flashcards_router;
import 'package:my_reviewer/src/routes/settings_router.dart' as settings_router;

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: docs_router.DocsRoute().location,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: docs_router.$appRoutes),
          StatefulShellBranch(routes: flashcards_router.$appRoutes),
          StatefulShellBranch(routes: settings_router.$appRoutes),
        ],
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShell({required this.navigationShell});

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.document_scanner),
            label: t.common.bottomNavbar.documents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.school),
            label: t.common.bottomNavbar.flashcards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: t.common.bottomNavbar.settings,
          ),
        ],
      ),
    );
  }
}
