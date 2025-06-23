import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/api/device_status.dart';
import 'package:hems_app/model/api/job.dart';
import 'package:hems_app/model/api/measurement.dart';
import 'package:hems_app/widget/device/timeshifter_card.dart';
import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays correctly no job', (tester) async {
    String id = 'dishwasher';
    DeviceStatus status = DeviceStatus(
      0,
      'dishwasher-house-0',
      false,
      0.0,
      -1,
      [],
      Measurement(0.0, 'W'),
      [],
    );

    await tester.pumpWidget(wrapWithMaterialApp(TimeshifterCard(id)));

    final timeshifterState =
        tester.state(find.byType(TimeshifterCard)) as TimeshifterState;
    timeshifterState.setState(() {
      timeshifterState.deviceStatus = Left(status);
    });

    await tester.pump();

    final idFinder = find.textContaining(id);
    expect(idFinder, findsOneWidget);
  });

  testWidgets('Displays correctly active job', (tester) async {
    String id = 'dishwasher';
    int time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Job job = Job(time - 59, time + 2 * 3600 + 21 * 60 + 59);

    DeviceStatus status = DeviceStatus(
      0,
      'dishwasher-house-0',
      true,
      100.0,
      0,
      [job],
      Measurement(100.0, 'W'),
      [],
      job,
    );

    await tester.pumpWidget(wrapWithMaterialApp(TimeshifterCard(id)));

    final timeshifterState =
        tester.state(find.byType(TimeshifterCard)) as TimeshifterState;
    timeshifterState.setState(() {
      timeshifterState.deviceStatus = Left(status);
      timeshifterState.timeDelay = 3600;
    });

    await tester.pump();

    final idFinder = find.textContaining(id);
    final remainderFinder = find.textContaining(RegExp(r'1[^0-9]+21'));

    expect(idFinder, findsOneWidget);
    expect(remainderFinder, findsOneWidget);
  });

  testWidgets('Displays correctly with scheduled job', (tester) async {
    String id = 'dishwasher';
    int time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Job job = Job(
      time + 2 * 3600 + 25 * 60 + 59,
      time + 4 * 3600 + 21 * 60 + 59,
    );

    DeviceStatus status = DeviceStatus(
      0,
      'dishwasher-house-0',
      false,
      0.0,
      -1,
      [job],
      Measurement(0.0, 'W'),
      [],
    );

    await tester.pumpWidget(wrapWithMaterialApp(TimeshifterCard(id)));

    final timeshifterState =
        tester.state(find.byType(TimeshifterCard)) as TimeshifterState;
    timeshifterState.setState(() {
      timeshifterState.deviceStatus = Left(status);
      timeshifterState.timeDelay = 3600;
    });

    await tester.pump();

    final idFinder = find.textContaining(id);
    final tillFinder = find.textContaining(RegExp(r'1[^0-9]+25'));
    final durationFinder = find.textContaining(RegExp(r'1[^0-9]+56'));

    expect(idFinder, findsOneWidget);
    expect(tillFinder, findsOneWidget);
    expect(durationFinder, findsOneWidget);
  });

  testWidgets('Displays error correctly', (tester) async {
    String message = 'not found';

    await tester.pumpWidget(wrapWithMaterialApp(TimeshifterCard('dishwasher')));

    final timeshifterState =
        tester.state(find.byType(TimeshifterCard)) as TimeshifterState;
    timeshifterState.setState(() {
      timeshifterState.deviceStatus = Right(message);
    });

    await tester.pump();

    final errorFinder = find.textContaining(message);
    expect(errorFinder, findsOne);
  });

  testWidgets('Displays progress correctly', (tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(TimeshifterCard('dishwasher')));

    final timeshifterState =
        tester.state(find.byType(TimeshifterCard)) as TimeshifterState;
    timeshifterState.setState(() {
      timeshifterState.deviceStatus = null;
    });

    await tester.pump();

    final progressFinder = find.bySubtype<ProgressIndicator>();
    expect(progressFinder, findsOne);
  });
}
