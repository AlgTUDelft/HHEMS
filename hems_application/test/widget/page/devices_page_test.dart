import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/l10n/app_localizations.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/device/battery_info_card.dart';
import 'package:hems_app/widget/device/solar_info_card.dart';
import 'package:hems_app/widget/device/thermal_info_card.dart';
import 'package:hems_app/widget/device/timeshifter_card.dart';
import 'package:hems_app/widget/page/devices_page.dart';
import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Shows Correct Widgets', (tester) async {
    final appState = AppState();

    final device1 = Device(houseId: 0, deviceId: '1', type: DeviceType.battery);
    final device2 = Device(houseId: 0, deviceId: '1', type: DeviceType.thermal);
    final device3 = Device(houseId: 0, deviceId: '1', type: DeviceType.solar);
    final device4 = Device(
      houseId: 0,
      deviceId: 'Dish Washer',
      type: DeviceType.timeshifter,
    );

    await tester.pumpWidget(wrapWithMaterialApp(DevicesPage()));

    final batteryFinder = find.byType(BatteryInfoCard);
    final thermalFinder = find.byType(ThermalInfoCard);
    final solarFinder = find.byType(SolarInfoCard);
    final timeshifterFinder = find.byType(TimeshifterCard);

    expect(batteryFinder, findsNothing);
    expect(thermalFinder, findsNothing);
    expect(solarFinder, findsNothing);
    expect(timeshifterFinder, findsNothing);

    final pageState =
        tester.state(find.byType(DevicesPage)) as DevicesPageState;
    pageState.setState(() {
      appState.devices = [device1, device2, device3, device4];
    });
    await tester.pump();

    await tester.scrollUntilVisible(batteryFinder, 400);
    expect(batteryFinder, findsOneWidget);
    await tester.scrollUntilVisible(thermalFinder, 400);
    expect(thermalFinder, findsOneWidget);
    await tester.scrollUntilVisible(solarFinder, 400);
    expect(solarFinder, findsOneWidget);
    await tester.scrollUntilVisible(timeshifterFinder, 400);
    expect(timeshifterFinder, findsOneWidget);

    appState.devices = [];
    await tester.pump();
  });

  testWidgets('Device management works', (tester) async {
    final appState = AppState();
    final l10n = lookupAppLocalizations(Locale('en'));

    await tester.pumpWidget(wrapWithMaterialApp(DevicesPage()));

    final buttonFinder = find.byType(FloatingActionButton);

    final batteryFinder = find.byType(BatteryInfoCard);
    final thermalFinder = find.byType(ThermalInfoCard);
    final solarFinder = find.byType(SolarInfoCard);

    final batteryCheckboxFinder = find.text(
      DeviceType.battery.localizedName(l10n),
    );
    final thermalCheckboxFinder = find.text(
      DeviceType.thermal.localizedName(l10n),
    );
    final solarCheckboxFinder = find.text(DeviceType.solar.localizedName(l10n));

    final doneFinder = find.text('Done');
    final cancelFinder = find.text('Cancel');

    expect(appState.devices.length, 0);
    expect(batteryFinder, findsNothing);
    expect(thermalFinder, findsNothing);
    expect(solarFinder, findsNothing);

    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(batteryCheckboxFinder, findsAny);
    expect(thermalCheckboxFinder, findsAny);
    expect(solarCheckboxFinder, findsAny);

    expect(cancelFinder, findsOneWidget);
    await tester.tap(batteryCheckboxFinder.first);
    await tester.tap(thermalCheckboxFinder.first);
    await tester.tap(solarCheckboxFinder.first);
    await tester.tap(cancelFinder);
    await tester.pumpAndSettle();

    expect(appState.devices.length, 0);
    expect(batteryFinder, findsNothing);
    expect(thermalFinder, findsNothing);
    expect(solarFinder, findsNothing);

    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(batteryCheckboxFinder, findsAny);
    expect(thermalCheckboxFinder, findsAny);
    expect(solarCheckboxFinder, findsAny);

    expect(doneFinder, findsOneWidget);
    await tester.tap(batteryCheckboxFinder.first);
    await tester.tap(thermalCheckboxFinder.first);
    await tester.tap(solarCheckboxFinder.first);
    await tester.tap(doneFinder);
    await tester.pumpAndSettle();

    expect(appState.devices.length, 3);
    await tester.scrollUntilVisible(batteryFinder, 400);
    expect(batteryFinder, findsOneWidget);
    await tester.scrollUntilVisible(thermalFinder, 400);
    expect(thermalFinder, findsOneWidget);
    await tester.scrollUntilVisible(solarFinder, 400);
    expect(solarFinder, findsOneWidget);

    appState.rooms = [
      Room(type: RoomType.bedroom, name: 'bedroom', devices: appState.devices),
    ];

    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(batteryCheckboxFinder, findsAny);
    expect(thermalCheckboxFinder, findsAny);
    expect(solarCheckboxFinder, findsAny);

    expect(doneFinder, findsOneWidget);
    await tester.tap(batteryCheckboxFinder.first);
    await tester.tap(solarCheckboxFinder.first);
    await tester.tap(doneFinder);
    await tester.pumpAndSettle();

    expect(appState.devices.length, 1);
    expect(batteryFinder, findsNothing);
    await tester.scrollUntilVisible(thermalFinder, 400);
    expect(thermalFinder, findsOneWidget);
    expect(solarFinder, findsNothing);
    expect(appState.rooms[0].devices.length, 1);
  });
}
