import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/widget/page/edit_room.dart';
import 'package:hems_app/widget/room_card.dart';
import '../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays correctly', (tester) async {
    String name = 'bedroom 1';
    Room room = Room(type: RoomType.bedroom, name: name, devices: []);

    await tester.pumpWidget(wrapWithMaterialApp(RoomCard(room)));

    final nameFinder = find.text(name);
    final iconFinder = find.byIcon(room.icon());

    expect(nameFinder, findsOneWidget);
    expect(iconFinder, findsOneWidget);
  });

  testWidgets('Tapping works', (tester) async {
    String name = 'bedroom 1';
    Room room = Room(type: RoomType.bedroom, name: name, devices: []);

    await tester.pumpWidget(wrapWithMaterialApp(RoomCard(room)));

    final editRoomFinder = find.byType(EditRoom);

    expect(editRoomFinder, findsNothing);

    await tester.tap(find.byType(RoomCard));
    await tester.pumpAndSettle();

    expect(editRoomFinder, findsOneWidget);
    final widget = tester.widget(editRoomFinder) as EditRoom;
    expect(widget.room, room);
  });
}
