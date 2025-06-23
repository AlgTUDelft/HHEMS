import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/api/thermal_info.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/widget/device/thermal_info_card.dart';
import '../../testing_utils/wrap_with_material_app.dart';

Device thermostat = Device(deviceId: "0", houseId: 0, type: DeviceType.thermal);

void main() {
  testWidgets('Displays correctly', (tester) async {
    ThermalInfo thermalInfo = ThermalInfo(100, 25, 100, 30);

    await tester.pumpWidget(
      wrapWithMaterialApp(ThermalInfoCard(thermostat: thermostat)),
    );

    final thermalState =
        tester.state(find.byType(ThermalInfoCard)) as ThermalInfoState;
    thermalState.setState(() {
      thermalState.thermalInfo = Left(thermalInfo);
    });

    await tester.pump();

    final paintFinder = find.byType(CustomPaint);

    expect(paintFinder, findsAny);
  });

  testWidgets('Displays error correctly', (tester) async {
    String message = 'not found';

    await tester.pumpWidget(
      wrapWithMaterialApp(ThermalInfoCard(thermostat: thermostat)),
    );

    final thermalState =
        tester.state(find.byType(ThermalInfoCard)) as ThermalInfoState;
    thermalState.setState(() {
      thermalState.thermalInfo = Right(message);
    });

    await tester.pump();

    final errorFinder = find.textContaining(message);
    expect(errorFinder, findsOne);
  });

  testWidgets('Displays progress correctly', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(ThermalInfoCard(thermostat: thermostat)),
    );

    final thermalState =
        tester.state(find.byType(ThermalInfoCard)) as ThermalInfoState;
    thermalState.setState(() {
      thermalState.thermalInfo = null;
    });

    await tester.pump();

    final progressFinder = find.bySubtype<ProgressIndicator>();
    expect(progressFinder, findsOne);
  });
}
