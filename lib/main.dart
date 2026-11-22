import 'dart:async';
import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/background_progress_banner_controller.dart';
import 'package:my_reviewer/src/controllers/settings_controller.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/models/qwen_ocr_model_spec.dart';
import 'package:my_reviewer/src/repositories/jobs/impl.dart';
import 'package:my_reviewer/src/repositories/jobs/interface.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/services/ui_sound_service.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:provider/provider.dart';

const String _buildHfToken = String.fromEnvironment('HF_TOKEN');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  if (Platform.isAndroid) {
    AndroidForegroundKeepAlive.initialize();
  }

  setupLocator();

  // Not awaited: the first screen should not wait for audio. Sounds are
  // silent until loading finishes, well before anyone opens a stack.
  unawaited(getIt<IUiSoundService>().init());
  unawaited(_initializeBackgroundServices());

  runApp(
    TranslationProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsController>.value(
            value: getIt<SettingsController>(),
          ),
          ChangeNotifierProvider<BackgroundProgressBannerController>.value(
            value: getIt<BackgroundProgressBannerController>(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> _initializeBackgroundServices() async {
  final downloader = getIt<IModelDownloader>();
  final jobQueue = getIt<IJobQueue>();
  final bannerController = getIt<BackgroundProgressBannerController>();

  await downloader.initialize();
  await jobQueue.initialize();

  bannerController.observe(downloader.watch(qwenOcrModelSpec.id));

  final userToken = "" as String?; //settings.huggingFaceToken?.trim();
  final token = (userToken != null && userToken.isNotEmpty)
      ? userToken
      : (_buildHfToken.isNotEmpty ? _buildHfToken : null);

  await downloader.ensureDownloaded(qwenOcrModelSpec, authToken: token);
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
