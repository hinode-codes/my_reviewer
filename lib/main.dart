import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/settings_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/services/ui_sound_service.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  setupLocator();

  // Not awaited: the first screen should not wait for audio. Sounds are
  // silent until loading finishes, well before anyone opens a stack.
  unawaited(getIt<IUiSoundService>().init());

  runApp(
    TranslationProvider(
      child: ChangeNotifierProvider<SettingsController>.value(
        value: getIt<SettingsController>(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: t.common.title,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routerConfig: GoRouter(
        navigatorKey: rootNavigatorKey,
        debugLogDiagnostics: true,
        initialLocation: DocsRouteData().location,
        routes: $appRoutes,
      ),
    );
  }
}