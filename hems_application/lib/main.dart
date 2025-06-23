import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hems_app/app_navigation.dart';
import 'package:hems_app/firebase/firebase_msg.dart';
import 'package:hems_app/firebase/firebase_options.dart';
import 'package:hems_app/l10n/app_localizations.dart';
import 'package:hems_app/material/themes.dart' as themes;
import 'package:hems_app/service/local_notifications_service.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/state/locale_notifier.dart';
import 'package:hems_app/state/stat_collector.dart';
import 'package:hems_app/state/theme_notifier.dart';
import 'package:provider/provider.dart';

/// The entry point of the HEMS (Home Energy Management System) app.
///
/// Initializes Flutter bindings, conditionally sets up Firebase (on supported platforms), and starts the app by running [HEMSApp].
/// Additionally, sets up [ThemeNotifier] and [LocaleNotifier] for quickly changing language and theme, using a [MultiProvider] for local persistence.
/// [StatCollector] is used for measuring devices consumption.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform != TargetPlatform.windows &&
      defaultTargetPlatform != TargetPlatform.linux) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMsg().initFCM();
  }

  await LocalNotificationsService().init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  ThemeNotifier themeNotifier = await ThemeNotifier.create();
  LocaleNotifier localeNotifier = await LocaleNotifier.create();
  StatCollector().startPolling();
  await AppState().initFromFile();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeNotifier),
        ChangeNotifierProvider(create: (_) => localeNotifier),
      ],
      child: const HEMSApp(),
    ),
  );
}

/// The root widget of the HEMS application.
///
/// Configures localization, theming, and sets [AppNavigation] as the home screen.
class HEMSApp extends StatelessWidget {
  const HEMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en'), Locale('nl')],
      locale: localeNotifier.locale,
      debugShowCheckedModeBanner: false,
      title: "Home Energy Management",
      theme: themes.lightTheme,
      darkTheme: themes.darkTheme,
      home: AppNavigation(),
      themeMode: themeNotifier.currentTheme,
    );
  }
}
