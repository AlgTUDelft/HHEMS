import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/page/create_job.dart';
import 'package:hems_app/widget/page/device_schedule_page.dart';
import 'package:hems_app/widget/schedule_view.dart';
import 'package:hems_app/widget/scheduled_job.dart';
import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays Correctly', (tester) async {

    final device1 = Device(
      houseId: 0,
      deviceId: 'Dish Washer',
      type: DeviceType.timeshifter,
    );
    final room1 = Room(
      type: RoomType.bathroom,
      name: 'bathroom 2',
      devices: [device1],
    );

    final job1 = DisplayJob(
      id: 0,
      room: room1,
      device: device1,
      startTime: DateTime.utc(2025, 6, 1, 1, 21),
      duration: Duration(seconds: 4285),
    );
    final job2 = DisplayJob(
      id: 1,
      room: room1,
      device: device1,
      startTime: DateTime.utc(2025, 6, 1, 1, 21).add(Duration(hours: 2)),
      duration: Duration(seconds: 3600),
    );

    await tester.pumpWidget(wrapWithMaterialApp(DeviceSchedulePage(deviceId: device1.deviceId)));

    

    final firstCardFinder = find.byType(Card).first;
    final scheduledJobFinder = find.descendant(
      of: firstCardFinder,
      matching: find.byType(ScheduledJob),
      skipOffstage: false,
    );
    final dividerFinder = find.byType(Divider);

    final schedulePageFinder = find.byType(DeviceSchedulePage);

    final pageState = tester.state(schedulePageFinder) as DeviceSchedulePageState;

    pageState.setState(() {
      pageState.jobs = [job1, job2];
    });
    await tester.pump();

    expect(scheduledJobFinder, findsExactly(2));
    expect(dividerFinder, findsExactly(1));

    final job3 = DisplayJob(
      id: 2,
      room: room1,
      device: device1,
      startTime: DateTime.utc(2025, 6, 1, 1, 21).add(Duration(days: 1)),
      duration: Duration(seconds: 360),
    );

    pageState.setState(() {
      pageState.jobs = [job1, job2, job3];
    });
    await tester.pump();

    findById(id) => find.byWidgetPredicate(
      (Widget widget) => widget is ScheduledJob && widget.id == id,
    );

    final widget1 = tester.widget(findById(0)) as ScheduledJob;
    final widget2 = tester.widget(findById(1)) as ScheduledJob;
    final widget3 = tester.widget(findById(2)) as ScheduledJob;

    expect(widget1.device, job1.device);
    expect(widget1.room, job1.room);
    expect(widget1.startTime, job1.startTime);
    expect(widget1.endTime.difference(widget1.startTime), job1.duration);

    expect(widget2.device, job2.device);
    expect(widget2.room, job2.room);
    expect(widget2.startTime, job2.startTime);
    expect(widget2.endTime.difference(widget2.startTime), job2.duration);

    expect(widget3.device, job3.device);
    expect(widget3.room, job3.room);
    expect(widget3.startTime, job3.startTime);
    expect(widget3.endTime.difference(widget3.startTime), job3.duration);
  });

  testWidgets("Create new job button works", (tester) async {
    final appState = AppState();
    final device1 = Device(
      houseId: 0,
      deviceId: "Dish Washer",
      type: DeviceType.timeshifter,
    );
    final room1 = Room(
      type: RoomType.bathroom,
      name: "bathroom 2",
      devices: [device1],
    );
    appState.addDevice(device1);
    appState.addRoom(room1);

    await tester.pumpWidget(wrapWithMaterialApp(DeviceSchedulePage(deviceId: "Dish Washer")));

    final schedulePageFinder = find.byType(DeviceSchedulePage);
    final createJobPageFinder = find.byType(CreateJob);
    final createButtonFinder = find.byType(FilledButton);

    expect(createButtonFinder, findsOneWidget);
    expect(schedulePageFinder, findsOneWidget);
    expect(createJobPageFinder, findsNothing);

    await tester.tap(createButtonFinder);
    await tester.pumpAndSettle();

    expect(schedulePageFinder, findsNothing);
    expect(createJobPageFinder, findsOneWidget);

    await tester.tap(find.backButton());
    await tester.pumpAndSettle();

    expect(schedulePageFinder, findsOneWidget);
    expect(createJobPageFinder, findsNothing);
  });
}