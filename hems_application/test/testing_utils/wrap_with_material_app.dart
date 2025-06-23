import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hems_app/l10n/app_localizations.dart';

MaterialApp wrapWithMaterialApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [Locale('en'), Locale('nl')],
    locale: Locale('en'),
    home: Scaffold(body: child),
  );
}
