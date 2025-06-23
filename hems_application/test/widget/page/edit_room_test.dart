import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/device/battery_info_card.dart';
import 'package:hems_app/widget/device/solar_info_card.dart';
import 'package:hems_app/widget/device/thermal_info_card.dart';
import 'package:hems_app/widget/device/timeshifter_card.dart';
import 'package:hems_app/widget/page/edit_room.dart';
import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays correctly', (tester) async {
    final appState = AppState();

    final device1 = Device(houseId: 0, deviceId: '1', type: DeviceType.battery);
    final device2 = Device(houseId: 0, deviceId: '1', type: DeviceType.thermal);
    final device3 = Device(houseId: 0, deviceId: '1', type: DeviceType.solar);
    final device4 = Device(
      houseId: 0,
      deviceId: 'Dish Washer',
      type: DeviceType.timeshifter,
    );
    final room1 = Room(
      type: RoomType.bathroom,
      name: 'bathroom 2',
      devices: [device1, device4],
    );
    final room2 = Room(
      type: RoomType.bedroom,
      name: 'bedroom 2',
      devices: [device3],
    );

    appState.devices = [device1, device2, device3, device4];
    appState.rooms = [room1, room2];

    await tester.pumpWidget(wrapWithMaterialApp(EditRoom(room: room1)));

    final nameFinder = find.text('bathroom 2');
    final buttonFinder = find.byType(FloatingActionButton);

    final batteryFinder = find.byType(BatteryInfoCard);
    final thermalFinder = find.byType(ThermalInfoCard);
    final solarFinder = find.byType(SolarInfoCard);
    final timeshifterFinder = find.byType(TimeshifterCard);

    expect(nameFinder, findsOneWidget);
    expect(buttonFinder, findsAtLeast(2));

    await tester.scrollUntilVisible(
      batteryFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(batteryFinder, findsOneWidget);
    expect(thermalFinder, findsNothing);
    expect(solarFinder, findsNothing);
    await tester.scrollUntilVisible(
      timeshifterFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(timeshifterFinder, findsOneWidget);
  });

  testWidgets('Displays correctly no device', (tester) async {
    final appState = AppState();

    final device1 = Device(houseId: 0, deviceId: '1', type: DeviceType.battery);
    final device2 = Device(houseId: 0, deviceId: '1', type: DeviceType.thermal);
    final device3 = Device(houseId: 0, deviceId: '1', type: DeviceType.solar);
    final device4 = Device(
      houseId: 0,
      deviceId: 'Dish Washer',
      type: DeviceType.timeshifter,
    );
    final room1 = Room(
      type: RoomType.bathroom,
      name: 'bathroom 2',
      devices: [],
    );
    final room2 = Room(
      type: RoomType.bedroom,
      name: 'bedroom 2',
      devices: [device3],
    );

    appState.devices = [device1, device2, device3, device4];
    appState.rooms = [room1, room2];

    await tester.pumpWidget(wrapWithMaterialApp(EditRoom(room: room1)));

    final nameFinder = find.text('bathroom 2');
    final buttonFinder = find.byType(FloatingActionButton);

    final batteryFinder = find.byType(BatteryInfoCard);
    final thermalFinder = find.byType(ThermalInfoCard);
    final solarFinder = find.byType(SolarInfoCard);
    final timeshifterFinder = find.byType(TimeshifterCard);

    expect(nameFinder, findsOneWidget);
    expect(buttonFinder, findsAtLeast(2));

    expect(batteryFinder, findsNothing);
    expect(thermalFinder, findsNothing);
    expect(solarFinder, findsNothing);
    expect(timeshifterFinder, findsNothing);
  });

  testWidgets('Delete room works correctly', (tester) async {
    final appState = AppState();

    final device1 = Device(houseId: 0, deviceId: '1', type: DeviceType.battery);
    final device2 = Device(houseId: 0, deviceId: '1', type: DeviceType.thermal);
    final device3 = Device(houseId: 0, deviceId: '1', type: DeviceType.solar);
    final device4 = Device(
      houseId: 0,
      deviceId: 'Dish Washer',
      type: DeviceType.timeshifter,
    );
    final room1 = Room(
      type: RoomType.bathroom,
      name: 'bathroom 2',
      devices: [device1, device4],
    );
    final room2 = Room(
      type: RoomType.bedroom,
      name: 'bedroom 2',
      devices: [device3],
    );

    appState.devices = [device1, device2, device3, device4];
    appState.rooms = [room1, room2];

    await tester.pumpWidget(wrapWithMaterialApp(EditRoom(room: room1)));

    final pageFinder = find.byType(EditRoom);
    final deleteButtonFinder = find.widgetWithIcon(
      FloatingActionButton,
      Icons.delete,
    );
    final cancelFinder = find.text('Cancel');
    final deleteFinder = find.text('Delete');

    expect(deleteButtonFinder, findsOneWidget);
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    expect(cancelFinder, findsOneWidget);
    await tester.tap(cancelFinder);
    await tester.pumpAndSettle();

    expect(pageFinder, findsOneWidget);
    expect(appState.rooms, contains(room1));

    expect(deleteButtonFinder, findsOneWidget);
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    expect(deleteFinder, findsOneWidget);
    await tester.tap(deleteFinder);
    await tester.pumpAndSettle();

    expect(pageFinder, findsNothing);
    expect(appState.rooms, isNot(contains(room1)));
  });

  testWidgets('Edit room works', (tester) async {
    final appState = AppState();

    final device1 = Device(houseId: 0, deviceId: '1', type: DeviceType.battery);
    final device2 = Device(houseId: 0, deviceId: '1', type: DeviceType.thermal);
    final device3 = Device(houseId: 0, deviceId: '1', type: DeviceType.solar);
    final device4 = Device(
      houseId: 0,
      deviceId: 'Dish Washer',
      type: DeviceType.timeshifter,
    );
    final room1 = Room(
      type: RoomType.bathroom,
      name: 'bathroom 2',
      devices: [device2],
    );
    final room2 = Room(
      type: RoomType.bedroom,
      name: 'bedroom 2',
      devices: [device3],
    );

    appState.devices = [device1, device2, device3, device4];
    appState.rooms = [room1, room2];

    await tester.pumpWidget(wrapWithMaterialApp(EditRoom(room: room1)));

    final editButtonFinder = find.widgetWithIcon(
      FloatingActionButton,
      Icons.edit,
    );
    final cancelFinder = find.text('Cancel');
    final saveFinder = find.textContaining('Save');

    final typeFinder = find.byType(DropdownButton<RoomType>);
    final context = tester.element(find.byType(EditRoom));

    final gardenFinder = find.text(RoomType.garden.localizedName(context.l10n));
    final nameFinder = find.byType(TextField);

    final batteryFinder = find.byType(BatteryInfoCard);
    final thermalFinder = find.byType(ThermalInfoCard);
    final solarFinder = find.byType(SolarInfoCard);
    final timeshifterFinder = find.byType(TimeshifterCard);

    final batteryCheckboxFinder = find.text(
      DeviceType.battery.localizedName(context.l10n),
    );
    final thermalCheckboxFinder = find.text(
      DeviceType.thermal.localizedName(context.l10n),
    );
    final solarCheckboxFinder = find.text(
      DeviceType.solar.localizedName(context.l10n),
    );
    final timeshifterCheckboxFinder = find.text(
      DeviceType.timeshifter.localizedName(context.l10n),
    );

    expect(batteryFinder, findsNothing);
    await tester.scrollUntilVisible(
      thermalFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(thermalFinder, findsOneWidget);
    expect(solarFinder, findsNothing);
    expect(timeshifterFinder, findsNothing);
    expect(find.text('bathroom 2'), findsAny);

    expect(editButtonFinder, findsOneWidget);
    await tester.tap(editButtonFinder);
    await tester.pumpAndSettle();

    expect(typeFinder, findsOneWidget);
    await tester.tap(typeFinder);
    await tester.pumpAndSettle();
    expect(gardenFinder, findsOneWidget);
    await tester.tap(gardenFinder);
    await tester.pumpAndSettle();
    expect(nameFinder, findsOneWidget);
    await tester.enterText(nameFinder, 'new name');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      batteryCheckboxFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(batteryCheckboxFinder, findsOneWidget);
    await tester.scrollUntilVisible(
      thermalCheckboxFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(thermalCheckboxFinder, findsOneWidget);
    await tester.tap(thermalCheckboxFinder);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      solarCheckboxFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(solarCheckboxFinder, findsOneWidget);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      timeshifterCheckboxFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(timeshifterCheckboxFinder, findsOneWidget);
    await tester.tap(timeshifterCheckboxFinder);
    await tester.pumpAndSettle();

    expect(cancelFinder, findsOneWidget);
    await tester.tap(cancelFinder);
    await tester.pump();

    expect(batteryFinder, findsNothing);
    await tester.scrollUntilVisible(
      thermalFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(thermalFinder, findsOneWidget);
    expect(solarFinder, findsNothing);
    expect(timeshifterFinder, findsNothing);
    expect(find.text('bathroom 2'), findsAny);

    expect(room1.type, RoomType.bathroom);
    expect(room1.name, 'bathroom 2');

    expect(editButtonFinder, findsOneWidget);
    await tester.tap(editButtonFinder);
    await tester.pumpAndSettle();

    expect(typeFinder, findsOneWidget);
    await tester.tap(typeFinder);
    await tester.pumpAndSettle();
    expect(gardenFinder, findsOneWidget);
    await tester.tap(gardenFinder);
    await tester.pumpAndSettle();
    expect(nameFinder, findsOneWidget);
    await tester.enterText(nameFinder, 'new name');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      batteryCheckboxFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(batteryCheckboxFinder, findsOneWidget);
    await tester.scrollUntilVisible(
      thermalCheckboxFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(thermalCheckboxFinder, findsOneWidget);
    await tester.tap(thermalCheckboxFinder);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      solarCheckboxFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(solarCheckboxFinder, findsOneWidget);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      timeshifterCheckboxFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(timeshifterCheckboxFinder, findsOneWidget);
    await tester.tap(timeshifterCheckboxFinder);
    await tester.pumpAndSettle();

    expect(saveFinder, findsOneWidget);
    await tester.tap(saveFinder);
    await tester.pump();

    expect(batteryFinder, findsNothing);
    expect(thermalFinder, findsNothing);
    expect(solarFinder, findsNothing);
    await tester.scrollUntilVisible(
      timeshifterFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(timeshifterFinder, findsOneWidget);
    expect(find.text('new name'), findsAny);

    expect(room1.type, RoomType.garden);
    expect(room1.name, 'new name');
  });
}
