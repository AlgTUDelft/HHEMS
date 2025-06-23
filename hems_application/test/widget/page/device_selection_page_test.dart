import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/page/device_selection_page.dart';
import '../../testing_utils/wrap_with_material_app.dart';

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
    final device3 = Device(
      houseId: 0,
      deviceId: 'Dryer',
      type: DeviceType.solar,
    );
    final device4 = Device(
      houseId: 0,
      deviceId: 'Shower',
      type: DeviceType.solar,
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

    appState.devices = [device1, device2, device3];
    appState.rooms = [room1, room2];

    await tester.pumpWidget(wrapWithMaterialApp(DeviceSelectionPage()));

    final dishFinder = find.text('Dish Washer');
    final washingFinder = find.text('Washing Machine');
    final dryerFinder = find.text('Dryer');
    final showerFinder = find.text('Shower');

    final bathroomFinder = find.text('bathroom 2');
    final otherFinder = find.text('Others');

    expect(dishFinder, findsOneWidget);
    expect(washingFinder, findsOneWidget);
    expect(dryerFinder, findsNothing);
    expect(showerFinder, findsNothing);

    expect(otherFinder, findsOneWidget);
    expect(bathroomFinder, findsOneWidget);
  });
}
