import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/state/locale_notifier.dart';
import 'package:hems_app/state/theme_notifier.dart';
import 'package:hems_app/widget/page/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays Correctly english', (tester) async {
    SharedPreferences.setMockInitialValues({
      ThemeNotifier.themePrefKey: false,
      LocaleNotifier.localePrefKey: "en",
    });
    ThemeNotifier themeNotifier = await ThemeNotifier.create();
    LocaleNotifier localeNotifier = await LocaleNotifier.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => themeNotifier),
          ChangeNotifierProvider(create: (_) => localeNotifier),
        ],
        child: wrapWithMaterialApp(SettingsPage()),
      ),
    );

    final switchFinder = find.byType(Switch);
    final dropdownFinder = find.byType(DropdownButton<Locale>);
    final englishFinder = find.text("English");
    final dutchFinder = find.text("Nederlands");
    final buttonFinder = find.byWidgetPredicate((w) => w is TextButton);

    expect(switchFinder, findsOneWidget);
    expect(dropdownFinder, findsOneWidget);
    expect(englishFinder, findsOneWidget);
    expect(dutchFinder, findsNothing);
    expect(buttonFinder, findsNWidgets(2));
  });

  testWidgets('Displays Correctly dutch', (tester) async {
    SharedPreferences.setMockInitialValues({
      ThemeNotifier.themePrefKey: false,
      LocaleNotifier.localePrefKey: "nl",
    });
    ThemeNotifier themeNotifier = await ThemeNotifier.create();
    LocaleNotifier localeNotifier = await LocaleNotifier.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => themeNotifier),
          ChangeNotifierProvider(create: (_) => localeNotifier),
        ],
        child: wrapWithMaterialApp(SettingsPage()),
      ),
    );

    final switchFinder = find.byType(Switch);
    final dropdownFinder = find.byType(DropdownButton<Locale>);
    final englishFinder = find.text("English");
    final dutchFinder = find.text("Nederlands");
    final buttonFinder = find.byWidgetPredicate((w) => w is TextButton);

    expect(switchFinder, findsOneWidget);
    expect(dropdownFinder, findsOneWidget);
    expect(englishFinder, findsNothing);
    expect(dutchFinder, findsOneWidget);
    expect(buttonFinder, findsNWidgets(2));
  });
}
