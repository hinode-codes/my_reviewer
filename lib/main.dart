import 'dart:async';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/controllers/ai_model_selector_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_dispatcher.dart';
import 'package:my_reviewer/src/shared/services/notifications/i_job_notification_service.dart';
import 'package:my_reviewer/src/shared/services/sound/i_sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  FlutterForegroundTask.initCommunicationPort();
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'ocr_transcription_fg',
      channelName: 'Document Transcription',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(15000),
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: false,
    ),
  );

  await setupLocator(isBackgroundWorker: false);

  getIt<IJobNotificationService>().initialize();

  // Not awaited: the first screen should not wait for audio. Sounds are
  // silent until loading finishes, well before anyone opens a stack.
  unawaited(getIt<ISoundService>().initialize());
  unawaited(_initializeBackgroundServices());

  runApp(TranslationProvider(child: const MyApp()));
}

Future<void> _initializeBackgroundServices() async {
  await getIt<AiModelSelectorController>().initialize();
  await getIt<IJobDispatcher>().initialize();
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermissionIfNeeded();
    });
  }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    if (!Platform.isAndroid) {
      return;
    }

    final status = await FlutterForegroundTask.checkNotificationPermission();

    if (status != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
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
