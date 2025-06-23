import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/api/solar_info.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/widget/device/solar_info_card.dart';
import '../../testing_utils/wrap_with_material_app.dart';

Device solarPanel = Device(deviceId: "0", houseId: 0, type: DeviceType.solar);

void main() {
  testWidgets('Displays correctly', (tester) async {
    SolarInfo solarInfo = SolarInfo(2000);

    await tester.pumpWidget(
      wrapWithMaterialApp(SolarInfoCard(solarPanel: solarPanel)),
    );

    final solarState =
        tester.state(find.byType(SolarInfoCard)) as SolarInfoState;
    solarState.setState(() {
      solarState.solarInfo = Left(solarInfo);
    });

    await tester.pump();

    final toggleFinder = find.byType(Switch);
    final productionFinder = find.textContaining('2000');

    expect(toggleFinder, findsOneWidget);
    expect(productionFinder, findsOneWidget);
  });

  testWidgets('Displays error correctly', (tester) async {
    String message = 'not found';

    await tester.pumpWidget(
      wrapWithMaterialApp(SolarInfoCard(solarPanel: solarPanel)),
    );

    final solarState =
        tester.state(find.byType(SolarInfoCard)) as SolarInfoState;
    solarState.setState(() {
      solarState.solarInfo = Right(message);
    });

    await tester.pump();

    final errorFinder = find.textContaining(message);
    expect(errorFinder, findsOne);
  });

  testWidgets('Displays progress correctly', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(SolarInfoCard(solarPanel: solarPanel)),
    );

    final solarState =
        tester.state(find.byType(SolarInfoCard)) as SolarInfoState;
    solarState.setState(() {
      solarState.solarInfo = null;
    });

    await tester.pump();

    final progressFinder = find.bySubtype<ProgressIndicator>();
    expect(progressFinder, findsOne);
  });
}
