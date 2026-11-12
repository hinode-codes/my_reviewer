import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';

class MainPageScreen extends StatelessWidget {
  const MainPageScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final strings = t.common;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            label: strings.bottomNavbar.docs,
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            label: strings.bottomNavbar.learn,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: strings.bottomNavbar.settings,
          ),
        ],
        onDestinationSelected: _onTap,
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
