import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/api/meter_info.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/widget/device/meter_info_card.dart';
import '../../testing_utils/wrap_with_material_app.dart';

Device meter = Device(deviceId: "0", houseId: 0, type: DeviceType.meter);

void main() {
  testWidgets('Displays correctly export', (tester) async {
    MeterInfo meterInfo = MeterInfo(100, 0, 0, 0, 1200, 1300);

    await tester.pumpWidget(wrapWithMaterialApp(MeterInfoCard(meter: meter)));

    final meterState =
        tester.state(find.byType(MeterInfoCard)) as MeterInfoState;
    meterState.setState(() {
      meterState.meterInfo = Left(meterInfo);
    });

    await tester.pump();

    final exportFinder = find.textContaining('100');
    final totalexportFinder = find.textContaining('1200');
    final totalimportFinder = find.textContaining('1300');

    expect(exportFinder, findsOneWidget);
    expect(totalexportFinder, findsOneWidget);
    expect(totalimportFinder, findsOneWidget);
  });

  testWidgets('Displays correctly import', (tester) async {
    MeterInfo meterInfo = MeterInfo(0, 250, 0, 0, 1200, 1300);

    await tester.pumpWidget(wrapWithMaterialApp(MeterInfoCard(meter: meter)));

    final meterState =
        tester.state(find.byType(MeterInfoCard)) as MeterInfoState;
    meterState.setState(() {
      meterState.meterInfo = Left(meterInfo);
    });

    await tester.pump();

    final importFinder = find.textContaining('250');
    final totalexportFinder = find.textContaining('1200');
    final totalimportFinder = find.textContaining('1300');

    expect(importFinder, findsOneWidget);
    expect(totalexportFinder, findsOneWidget);
    expect(totalimportFinder, findsOneWidget);
  });

  testWidgets('Displays error correctly', (tester) async {
    String message = 'not found';

    await tester.pumpWidget(wrapWithMaterialApp(MeterInfoCard(meter: meter)));

    final meterState =
        tester.state(find.byType(MeterInfoCard)) as MeterInfoState;
    meterState.setState(() {
      meterState.meterInfo = Right(message);
    });

    await tester.pump();

    final errorFinder = find.textContaining(message);
    expect(errorFinder, findsOne);
  });

  testWidgets('Displays progress correctly', (tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(MeterInfoCard(meter: meter)));

    final meterState =
        tester.state(find.byType(MeterInfoCard)) as MeterInfoState;
    meterState.setState(() {
      meterState.meterInfo = null;
    });

    await tester.pump();

    final progressFinder = find.bySubtype<ProgressIndicator>();
    expect(progressFinder, findsOne);
  });
}
