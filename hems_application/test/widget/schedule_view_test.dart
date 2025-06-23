import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/schedule_view.dart';
import 'package:hems_app/widget/scheduled_job.dart';
import '../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays Correctly', (tester) async {
    final appState = AppState();

    final device1 = Device(
      houseId: 0,
      deviceId: 'Dish Washer',
      type: DeviceType.timeshifter,
    );
    final device2 = Device(
      houseId: 0,
      deviceId: 'Washing Machine',
      type: DeviceType.timeshifter,
    );
    final room1 = Room(
      type: RoomType.bathroom,
      name: 'bathroom 2',
      devices: [device1],
    );
    final room2 = Room(type: RoomType.bedroom, name: 'bedroom 2', devices: []);

    final job1 = DisplayJob(
      id: 0,
      room: room1,
      device: device1,
      startTime: DateTime.utc(2025, 6, 1, 1, 21),
      duration: Duration(seconds: 4285),
    );
    final job2 = DisplayJob(
      id: 1,
      room: room2,
      device: device2,
      startTime: DateTime.utc(2025, 6, 1, 1, 21).add(Duration(hours: 2)),
      duration: Duration(seconds: 3600),
    );

    await tester.pumpWidget(wrapWithMaterialApp(ScheduleView(jobs: [job1, job2], onCancelJob: (id, startTime, device) {})));

    final firstCardFinder = find.byType(Card).first;
    final scheduledJobFinder = find.descendant(
      of: firstCardFinder,
      matching: find.byType(ScheduledJob),
      skipOffstage: false,
    );
    final dividerFinder = find.byType(Divider);

    final scheduleViewFinder = find.byType(ScheduleView);

    expect(scheduledJobFinder, findsExactly(2));
    expect(dividerFinder, findsExactly(1));

    final context = tester.element(scheduleViewFinder);
    final job3 = DisplayJob(
      id: 2,
      room: appState.othersRoom(context),
      device: device1,
      startTime: DateTime.utc(2025, 6, 1, 1, 21).add(Duration(days: 1)),
      duration: Duration(seconds: 360),
    );

    await tester.pumpWidget(wrapWithMaterialApp(ScheduleView(jobs: [job1, job2, job3], onCancelJob: (id, startTime, device) {})));

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
}