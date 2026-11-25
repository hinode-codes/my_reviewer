import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/locators/main_locator.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/services/foreground_tasks/foreground_task_commander.dart';
import 'package:my_reviewer/src/shared/services/foreground_tasks/foreground_task_type.dart';

Future<void> main() async {
  await setupLocator();

  runApp(TranslationProvider(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: DocsRouteData().location,
    routes: $appRoutes,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getIt<ForegroundTaskCommander>().initSetup();
      getIt<ForegroundTaskCommander>().init();

      if (await getIt<IJobReadRepository>().countQueued() != 0) {
        getIt<ForegroundTaskCommander>().start(ForegroundTaskType.ocr);
      }
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: t.common.title,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      routerConfig: _router,
    );
  }
}
