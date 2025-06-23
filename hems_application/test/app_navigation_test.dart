import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/main.dart';
import 'package:hems_app/state/locale_notifier.dart';
import 'package:hems_app/state/theme_notifier.dart';
import 'package:hems_app/widget/page/devices_page.dart';
import 'package:hems_app/widget/page/home_page.dart';
import 'package:hems_app/widget/page/schedules_page.dart';
import 'package:hems_app/widget/page/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Navigation tests', (tester) async {
    SharedPreferences.setMockInitialValues({
      ThemeNotifier.themePrefKey: true,
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
        child: const HEMSApp(),
      ),
    );

    final appbarFinder = find.byType(AppBar);
    final titleFinder = find.descendant(
      of: appbarFinder,
      matching: find.byType(Text),
    );

    final navigationFinder = find.byType(NavigationBar);
    final destionationFinder = find.byType(NavigationDestination);

    final homepageFinder = find.byType(HomePage);
    final schedulespageFinder = find.byType(SchedulesPage);
    final devicespageFinder = find.byType(DevicesPage);
    final settingspageFinder = find.byType(SettingsPage);

    expect(appbarFinder, findsOneWidget);
    expect(titleFinder, findsAtLeast(1));

    expect(navigationFinder, findsOneWidget);
    expect(destionationFinder, findsExactly(4));

    expect(homepageFinder, findsOneWidget);
    expect(schedulespageFinder, findsNothing);
    expect(devicespageFinder, findsNothing);
    expect(settingspageFinder, findsNothing);

    await tester.tap(destionationFinder.at(1));
    await tester.pump();

    expect(appbarFinder, findsOneWidget);
    expect(titleFinder, findsAtLeast(1));

    expect(navigationFinder, findsOneWidget);
    expect(destionationFinder, findsExactly(4));

    expect(homepageFinder, findsNothing);
    expect(schedulespageFinder, findsOneWidget);
    expect(devicespageFinder, findsNothing);
    expect(settingspageFinder, findsNothing);

    await tester.tap(destionationFinder.at(2));
    await tester.pump();

    expect(appbarFinder, findsOneWidget);
    expect(titleFinder, findsAtLeast(1));

    expect(navigationFinder, findsOneWidget);
    expect(destionationFinder, findsExactly(4));

    expect(homepageFinder, findsNothing);
    expect(schedulespageFinder, findsNothing);
    expect(devicespageFinder, findsOneWidget);
    expect(settingspageFinder, findsNothing);

    await tester.tap(destionationFinder.at(3));
    await tester.pump();

    expect(appbarFinder, findsOneWidget);
    expect(titleFinder, findsAtLeast(1));

    expect(navigationFinder, findsOneWidget);
    expect(destionationFinder, findsExactly(4));

    expect(homepageFinder, findsNothing);
    expect(schedulespageFinder, findsNothing);
    expect(devicespageFinder, findsNothing);
    expect(settingspageFinder, findsOneWidget);

    await tester.tap(destionationFinder.at(2));
    await tester.pump();

    expect(appbarFinder, findsOneWidget);
    expect(titleFinder, findsAtLeast(1));

    expect(navigationFinder, findsOneWidget);
    expect(destionationFinder, findsExactly(4));

    expect(homepageFinder, findsNothing);
    expect(schedulespageFinder, findsNothing);
    expect(devicespageFinder, findsOneWidget);
    expect(settingspageFinder, findsNothing);

    await tester.tap(destionationFinder.at(0));
    await tester.pump();

    expect(appbarFinder, findsOneWidget);
    expect(titleFinder, findsAtLeast(1));

    expect(navigationFinder, findsOneWidget);
    expect(destionationFinder, findsExactly(4));

    expect(homepageFinder, findsOneWidget);
    expect(schedulespageFinder, findsNothing);
    expect(devicespageFinder, findsNothing);
    expect(settingspageFinder, findsNothing);
  });
}
