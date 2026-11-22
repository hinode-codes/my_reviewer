import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/background_progress_banner_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/widgets/common/background_progress_banner.dart';
import 'package:provider/provider.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  // Index of JobsShellBranchData in routes.dart (0: Docs, 1: Learn, 2: Jobs, 3: Settings)
  static const int _jobsBranchIndex = 2;

  GoRouterDelegate? _routerDelegate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncJobsSuppression());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.of(context).routerDelegate;
    if (_routerDelegate != delegate) {
      _routerDelegate?.removeListener(_syncJobsSuppression);
      _routerDelegate = delegate..addListener(_syncJobsSuppression);
    }
  }

  @override
  void didUpdateWidget(covariant MainPageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncJobsSuppression();
  }

  @override
  void dispose() {
    _routerDelegate?.removeListener(_syncJobsSuppression);
    super.dispose();
  }

  void _syncJobsSuppression() {
    if (!mounted) return;
    final isOnJobs = widget.navigationShell.currentIndex == _jobsBranchIndex;
    context.read<BackgroundProgressBannerController>().setSuppressedOnJobsRoute(
      isOnJobs,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = t.common;

    return BackgroundProgressBanner(
      onTap: () => widget.navigationShell.goBranch(_jobsBranchIndex),
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.description_outlined),
              label: strings.bottomNavbar.docs,
            ),
            NavigationDestination(
              icon: const Icon(Icons.school_outlined),
              label: strings.bottomNavbar.learn,
            ),
            NavigationDestination(
              icon: const Icon(Icons.queue_outlined),
              label: strings.bottomNavbar.queue,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              label: strings.bottomNavbar.settings,
            ),
          ],
        ),
      ),
    );
  }
}
