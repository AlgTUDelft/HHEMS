import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/widget/scheduled_job.dart';
import '../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays correctly without displayTimeLeft', (tester) async {
    String roomName = 'bedroom 1';
    String deviceId = 'dishwasher';
    Device device = Device(
      type: DeviceType.timeshifter,
      houseId: 0,
      deviceId: deviceId,
    );
    Room room = Room(type: RoomType.bedroom, name: roomName, devices: []);

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ScheduledJob(
          id: 0,
          onCancelJob: (id, startTime, device) {},
          device: device,
          room: room,
          startTime: DateTime.utc(2025, 6, 1, 1, 21),
          endTime: DateTime.utc(2025, 6, 1, 13, 31),
          displayTimeLeft: false,
        ),
      ),
    );

    final roomNameFinder = find.text(roomName);
    final roomIconFinder = find.byIcon(room.icon());
    final deviceIdFinder = find.text(deviceId);
    final deviceIconFinder = find.byIcon(device.type.iconData);
    final startTimeFinder = find.textContaining('01:21');
    final endTimeFinder = find.textContaining('13:31');
    final cancelFinder = find.textContaining('Cancel');

    expect(roomNameFinder, findsOneWidget);
    expect(roomIconFinder, findsOneWidget);
    expect(deviceIdFinder, findsOneWidget);
    expect(deviceIconFinder, findsOneWidget);
    expect(startTimeFinder, findsOneWidget);
    expect(endTimeFinder, findsOneWidget);
    expect(cancelFinder, findsNothing);

    await tester.tap(find.byType(ScheduledJob));
    await tester.pumpAndSettle();

    expect(roomNameFinder, findsOneWidget);
    expect(roomIconFinder, findsOneWidget);
    expect(deviceIdFinder, findsOneWidget);
    expect(deviceIconFinder, findsOneWidget);
    expect(startTimeFinder, findsOneWidget);
    expect(endTimeFinder, findsOneWidget);
    expect(cancelFinder, findsOneWidget);
  });

  testWidgets('Displays correctly with displayTimeLeft', (tester) async {
    String roomName = 'bedroom 1';
    String deviceId = 'dishwasher';
    Device device = Device(
      type: DeviceType.timeshifter,
      houseId: 0,
      deviceId: deviceId,
    );
    Room room = Room(type: RoomType.bedroom, name: roomName, devices: []);

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ScheduledJob(
          id: 0,
          onCancelJob: (id, startTime, device) {},
          device: device,
          room: room,
          startTime: DateTime.utc(2025, 6, 1, 1, 21),
          endTime: DateTime.utc(2025, 6, 1, 13, 31),
          displayTimeLeft: true,
        ),
      ),
    );

    final roomNameFinder = find.text(roomName);
    final roomIconFinder = find.byIcon(room.icon());
    final deviceIdFinder = find.text(deviceId);
    final deviceIconFinder = find.byIcon(device.type.iconData);
    final startTimeFinder = find.textContaining('01:21');
    final endTimeFinder = find.textContaining('13:31');
    final cancelFinder = find.textContaining('Cancel');

    expect(roomNameFinder, findsOneWidget);
    expect(roomIconFinder, findsOneWidget);
    expect(deviceIdFinder, findsOneWidget);
    expect(deviceIconFinder, findsOneWidget);
    expect(startTimeFinder, findsExactly(2));
    expect(endTimeFinder, findsOneWidget);
    expect(cancelFinder, findsNothing);

    await tester.tap(find.byType(ScheduledJob));
    await tester.pumpAndSettle();

    expect(roomNameFinder, findsOneWidget);
    expect(roomIconFinder, findsOneWidget);
    expect(deviceIdFinder, findsOneWidget);
    expect(deviceIconFinder, findsOneWidget);
    expect(startTimeFinder, findsExactly(2));
    expect(endTimeFinder, findsOneWidget);
    expect(cancelFinder, findsOneWidget);
  });

  testWidgets('No expansion with id -1', (tester) async {
    String roomName = 'bedroom 1';
    String deviceId = 'dishwasher';
    Device device = Device(
      type: DeviceType.timeshifter,
      houseId: 0,
      deviceId: deviceId,
    );
    Room room = Room(type: RoomType.bedroom, name: roomName, devices: []);

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ScheduledJob(
          id: -1,
          onCancelJob: (id, startTime, device) {},
          device: device,
          room: room,
          startTime: DateTime.utc(2025, 6, 1, 1, 21),
          endTime: DateTime.utc(2025, 6, 1, 13, 31),
          displayTimeLeft: true,
        ),
      ),
    );

    final cancelFinder = find.textContaining('Cancel');

    expect(cancelFinder, findsNothing);

    await tester.tap(find.byType(ScheduledJob));
    await tester.pumpAndSettle();

    expect(cancelFinder, findsNothing);
  });
}
