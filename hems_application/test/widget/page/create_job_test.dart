import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/page/create_job.dart';
import 'package:hems_app/widget/page/device_selection_page.dart';
import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Create job buttons work', (tester) async {
    final appState = AppState();
    appState.devices = [
      Device(houseId: 0, deviceId: 'Dish Washer', type: DeviceType.timeshifter),
    ];

    await tester.pumpWidget(wrapWithMaterialApp(CreateJob()));

    final deviceFinder = find.text('Device');
    final dateFinder = find.text('Date');
    final startTimeFinder = find.text('Start Time');
    final durationFinder = find.text('Duration');
    final createFinder = find.text('Create job');

    final deviceSelPageFinder = find.byType(DeviceSelectionPage);
    final createJobPageFinder = find.byType(CreateJob);

    final durationPickerFinder = find.byType(DurationPickerDialog);
    final datePickerFinder = find.byType(DatePickerDialog);
    final timePickerFinder = find.byType(TimePickerDialog);

    final okFinder = find.text('OK');
    final dishWasherFinder = find.text('Dish Washer');

    expect(deviceFinder, findsOneWidget);
    expect(dateFinder, findsOneWidget);
    expect(startTimeFinder, findsOneWidget);
    expect(durationFinder, findsOneWidget);
    expect(createFinder, findsOneWidget);

    expect(createJobPageFinder, findsOneWidget);
    expect(deviceSelPageFinder, findsNothing);

    expect(durationPickerFinder, findsNothing);
    expect(datePickerFinder, findsNothing);
    expect(timePickerFinder, findsNothing);
    expect(dishWasherFinder, findsNothing);

    await tester.tap(deviceFinder);
    await tester.pumpAndSettle();

    expect(createJobPageFinder, findsNothing);
    expect(deviceSelPageFinder, findsOneWidget);

    await tester.tap(find.text('Dish Washer'));
    await tester.pumpAndSettle();

    final pageState = tester.state(createJobPageFinder) as CreateJobState;
    pageState.setState(() {
      pageState.minimumDuration = Duration(seconds: 3600);
    });
    await tester.pump();

    await tester.tap(durationFinder);
    await tester.pumpAndSettle();

    expect(durationPickerFinder, findsOneWidget);
    expect(datePickerFinder, findsNothing);
    expect(timePickerFinder, findsNothing);
    expect(dishWasherFinder, findsOneWidget);

    await tester.tap(okFinder);
    await tester.pumpAndSettle();

    await tester.tap(dateFinder);
    await tester.pumpAndSettle();

    expect(durationPickerFinder, findsNothing);
    expect(datePickerFinder, findsOneWidget);
    expect(timePickerFinder, findsNothing);
    expect(dishWasherFinder, findsOneWidget);

    await tester.tap(okFinder);
    await tester.pumpAndSettle();

    await tester.tap(startTimeFinder);
    await tester.pumpAndSettle();

    expect(durationPickerFinder, findsNothing);
    expect(datePickerFinder, findsNothing);
    expect(timePickerFinder, findsOneWidget);
    expect(dishWasherFinder, findsOneWidget);

    await tester.tap(okFinder);
    await tester.pumpAndSettle();
  });

  testWidgets('Minimum duration enforced', (tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(CreateJob()));

    final durationFinder = find.text('Duration');
    final createJobPageFinder = find.byType(CreateJob);
    final snackbarFinder = find.byType(SnackBar);
    final okFinder = find.text('OK');

    final pageState = tester.state(createJobPageFinder) as CreateJobState;

    expect(durationFinder, findsOneWidget);
    expect(createJobPageFinder, findsOneWidget);
    expect(snackbarFinder, findsNothing);

    pageState.setState(() {
      pageState.minimumDuration = Duration(seconds: 3600);
      pageState.device = Device(
        houseId: 0,
        deviceId: 'Dish Washer',
        type: DeviceType.timeshifter,
      );
    });
    await tester.pump();

    await tester.tap(durationFinder);
    await tester.pumpAndSettle();

    pageState.setState(() {
      pageState.minimumDuration = Duration(seconds: 7200);
    });
    await tester.pump();

    await tester.tap(okFinder);
    await tester.pumpAndSettle();

    expect(snackbarFinder, findsOneWidget);
  });
}
