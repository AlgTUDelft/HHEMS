import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/analytics/animated_power_flow.dart';
import 'package:hems_app/widget/analytics/consumption_chart.dart';
import 'package:hems_app/widget/room_card.dart';

/// Home Page which is displayed on startup.
/// 
/// A widget that displays:
/// - The [Room]s created by the user.
/// - A network diagram displaying the flow of power from producer devices to consumer
///   devices.
/// - A bar chart displaying the power consumption of all of the user's devices over
///   the past minute.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  /// Builds the widget tree.
  ///
  /// The method constructs a [ListenableBuilder] which contains:
  /// - [AnimatedPowerFlow] which is the network diagram of power flow.
  /// - A grid view of rooms created by the user displayed using their associated [RoomCard]s.
  /// - [ConsumptionChart] which is the bar chart of the power consumption of all of the user's
  ///   devices over the past minute.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, child) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          context.l10n.yourRooms,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: newRoomDialog,
                        ),
                      ),
                    ],
                  ),
                  AppState().rooms.isEmpty
                  ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(2), 
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(context.l10n.tryCreatingARoom, style: Theme.of(context).textTheme.bodyLarge),
                                    SizedBox(height: 8),
                                    OutlinedButton(onPressed: newRoomDialog, child: Text(context.l10n.createNewRoom)),
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ],
                  )
                  : GridView.count(
                    shrinkWrap: true,
                    childAspectRatio: 1.5,
                    crossAxisCount: 3,
                    physics: NeverScrollableScrollPhysics(),
                    children: (AppState().rooms + [AppState().othersRoom(context)]).map((e) {
                      return RoomCard(e);
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text(
                    context.l10n.powerFlow,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  AnimatedPowerFlow(),
                  SizedBox(height: 16),
                  Text(
                    context.l10n.deviceAnalytics,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  ConsumptionChart(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Dialog for creating a new room on the home page.
  /// 
  /// Can choose from a dropdown of predefined rooms and prompts the user to enter the name of the room.
  void newRoomDialog() async {
    final newRoom = await showDialog<Room>(
      context: context,
      builder: (context) {
        String name = "";
        RoomType? type;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(context.l10n.createNewRoom),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<RoomType>(
                        dropdownColor: Theme.of(context).cardTheme.color,
                        items:
                            RoomType.values.map((e) {
                              return DropdownMenuItem<RoomType>(
                                value: e,
                                child: Text(e.localizedName(context.l10n)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            type = value;
                          });
                        },
                        value: type,
                        hint: Text(context.l10n.chooseRoomType),
                      ),
                      TextField(
                        onChanged: (value) {
                          name = value;
                        },
                        decoration: InputDecoration(
                          hintText: context.l10n.enterRoomName,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (type != null && name.isNotEmpty) {
                      Navigator.of(
                        context,
                      ).pop(Room(type: type!, name: name, devices: []));
                    }
                  },
                  child: Text(context.l10n.create),
                ),
              ],
            );
          },
        );
      },
    );

    if (newRoom != null) {
      setState(() {
        AppState().addRoom(newRoom);
      });
    }
  }
}
