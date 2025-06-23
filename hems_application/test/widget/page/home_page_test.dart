import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/analytics/animated_power_flow.dart';
import 'package:hems_app/widget/analytics/consumption_chart.dart';
import 'package:hems_app/widget/page/home_page.dart';
import 'package:hems_app/widget/room_card.dart';
import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays Correctly', (tester) async {
    final appState = AppState();

    final room1 = Room(
      type: RoomType.bathroom,
      name: 'bathroom 2',
      devices: [],
    );
    final room2 = Room(type: RoomType.bedroom, name: 'bedroom 2', devices: []);

    await tester.pumpWidget(wrapWithMaterialApp(HomePage()));

    final roomFinder = find.byType(RoomCard);
    final flowFinder = find.byType(AnimatedPowerFlow);
    final chartFinder = find.byType(ConsumptionChart);

    expect(roomFinder, findsNothing);
    await tester.scrollUntilVisible(
      flowFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(flowFinder, findsOneWidget);
    await tester.scrollUntilVisible(
      chartFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(chartFinder, findsOneWidget);

    final pageState = tester.state(find.byType(HomePage)) as HomePageState;
    pageState.setState(() {
      appState.rooms = [room1, room2];
    });

    await tester.scrollUntilVisible(
      find.widgetWithText(RoomCard, 'bathroom 2'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(roomFinder, findsExactly(3));

    final widget1 = tester.widget(roomFinder.at(0)) as RoomCard;
    final widget2 = tester.widget(roomFinder.at(1)) as RoomCard;

    expect(widget1.room, room1);
    expect(widget2.room, room2);
  });

  testWidgets('Displays Correctly', (tester) async {
    final appState = AppState();

    // final room1 = Room(
    //   type: RoomType.bathroom,
    //   name: 'bathroom 2',
    //   devices: [],
    // );
    // final room2 = Room(type: RoomType.bedroom, name: 'bedroom 2', devices: []);

    await tester.pumpWidget(wrapWithMaterialApp(HomePage()));

    final roomFinder = find.byType(RoomCard);
    final addFinder = find.widgetWithIcon(IconButton, Icons.add);

    final typeFinder = find.byType(DropdownButton<RoomType>);

    final context = tester.element(find.byType(HomePage));
    final gardenFinder = find.text(RoomType.garden.localizedName(context.l10n));
    final nameFinder = find.byType(TextField);

    final cancelFinder = find.text('Cancel');
    final createFinder = find.widgetWithText(FilledButton, 'Create');

    expect(roomFinder, findsExactly(3));

    expect(addFinder, findsOneWidget);
    await tester.tap(addFinder);
    await tester.pump();

    expect(typeFinder, findsOneWidget);
    await tester.tap(typeFinder);
    await tester.pump();
    expect(gardenFinder, findsOneWidget);
    await tester.tap(gardenFinder);
    await tester.pump();
    expect(nameFinder, findsOneWidget);
    await tester.enterText(nameFinder, 'new name');
    await tester.pump();

    expect(cancelFinder, findsOneWidget);
    await tester.tap(cancelFinder);
    await tester.pump();

    expect(roomFinder, findsExactly(3));
    expect(appState.rooms.length, 2);

    expect(addFinder, findsOneWidget);
    await tester.tap(addFinder);
    await tester.pump();

    expect(typeFinder, findsOneWidget);
    await tester.tap(typeFinder);
    await tester.pump();
    expect(gardenFinder, findsOneWidget);
    await tester.tap(gardenFinder);
    await tester.pump();
    expect(nameFinder, findsOneWidget);
    await tester.enterText(nameFinder, 'new name');
    await tester.pump();

    expect(createFinder, findsOneWidget);
    await tester.tap(createFinder);
    await tester.pump();

    final newRoom = Room(type: RoomType.garden, name: 'new name', devices: []);

    expect(appState.rooms.length, 3);
    expect(appState.rooms, contains(newRoom));

    expect(roomFinder, findsExactly(4));
    final widget = tester.widget(roomFinder.at(2)) as RoomCard;

    expect(widget.room, newRoom);
  });
}
