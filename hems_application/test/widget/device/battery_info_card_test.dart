import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/api/battery_info.dart';
import 'package:hems_app/model/api/battery_status.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/widget/device/battery_info_card.dart';
import '../../testing_utils/wrap_with_material_app.dart';

Device battery = Device(deviceId: "0", houseId: 0, type: DeviceType.battery);

void main() {
  testWidgets('Displays correctly', (tester) async {
    BatteryInfo batInfo1 = BatteryInfo(
      2000,
      100,
      100,
      100,
      1000,
      BatteryStatus.idle,
    );
    BatteryInfo batInfo2 = BatteryInfo(
      2000,
      100,
      100,
      100,
      1000,
      BatteryStatus.idle,
      0,
    );
    BatteryInfo batInfo3 = BatteryInfo(
      2000,
      100,
      100,
      100,
      1000,
      BatteryStatus.charging,
    );
    BatteryInfo batInfo4 = BatteryInfo(
      2000,
      100,
      100,
      100,
      1000,
      BatteryStatus.charging,
      0,
    );
    BatteryInfo batInfo5 = BatteryInfo(
      2000,
      100,
      100,
      100,
      1000,
      BatteryStatus.discharging,
    );
    BatteryInfo batInfo6 = BatteryInfo(
      2000,
      100,
      100,
      100,
      1000,
      BatteryStatus.discharging,
      0,
    );

    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryInfoCard(battery: battery)),
    );

    final batteryState =
        tester.state(find.byType(BatteryInfoCard)) as BatteryState;
    final percentageFinder = find.textContaining('50%');

    batteryState.setState(() {
      batteryState.batInfo = Left(batInfo1);
    });
    await tester.pump();
    expect(percentageFinder, findsOne);

    batteryState.setState(() {
      batteryState.batInfo = Left(batInfo2);
    });
    await tester.pump();
    expect(percentageFinder, findsOne);

    batteryState.setState(() {
      batteryState.batInfo = Left(batInfo3);
    });
    await tester.pump();
    expect(percentageFinder, findsOne);

    batteryState.setState(() {
      batteryState.batInfo = Left(batInfo4);
    });
    await tester.pump();
    expect(percentageFinder, findsOne);

    batteryState.setState(() {
      batteryState.batInfo = Left(batInfo5);
    });
    await tester.pump();
    expect(percentageFinder, findsOne);

    batteryState.setState(() {
      batteryState.batInfo = Left(batInfo6);
    });
    await tester.pump();
    expect(percentageFinder, findsOne);
  });

  testWidgets('Displays error correctly', (tester) async {
    String message = 'not found';

    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryInfoCard(battery: battery)),
    );

    final batteryState =
        tester.state(find.byType(BatteryInfoCard)) as BatteryState;
    batteryState.setState(() {
      batteryState.batInfo = Right(message);
    });

    await tester.pump();

    final errorFinder = find.textContaining(message);
    expect(errorFinder, findsOne);
  });

  testWidgets('Displays progress correctly', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryInfoCard(battery: battery)),
    );

    final batteryState =
        tester.state(find.byType(BatteryInfoCard)) as BatteryState;
    batteryState.setState(() {
      batteryState.batInfo = null;
    });

    await tester.pump();

    final progressFinder = find.bySubtype<ProgressIndicator>();
    expect(progressFinder, findsOne);
  });
}
