import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/controllers/ai_model_selector_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/services/jobs/local_job_queue_runner.dart';
import 'package:my_reviewer/src/shared/services/notifications/i_job_notification_service.dart';
import 'package:my_reviewer/src/shared/services/sound/i_sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  
  const hfToken = String.fromEnvironment('HF_TOKEN');

  await setupLocator(
    readHuggingFaceToken: hfToken.isEmpty ? null : () async => hfToken,
  );

  getIt<IJobNotificationService>().initialize();

  // Not awaited: the first screen should not wait for audio. Sounds are
  // silent until loading finishes, well before anyone opens a stack.
  unawaited(getIt<ISoundService>().initialize());
  unawaited(_initializeBackgroundServices());

  runApp(TranslationProvider(child: const MyApp()));
}

Future<void> _initializeBackgroundServices() async {
  await getIt<AiModelSelectorController>().initialize();
  await getIt<LocalJobQueueRunner>().start();
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
