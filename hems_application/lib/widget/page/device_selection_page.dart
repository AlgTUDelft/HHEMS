import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/state/app_state.dart';


/// Page for selecting a timeshifter device to schedule.
///
/// The devices are accompanied by their respective room icon
class DeviceSelectionPage extends StatelessWidget {
  DeviceSelectionPage({super.key});

  final rooms = AppState().rooms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.selectADevice)),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children:
              (rooms + [AppState().othersRoom(context)]).map((room) {
                return Column(
                  children:
                      <Widget>[
                        Row(
                          children: [
                            Icon(room.icon(), size: 24, color: room.color()),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                room.name,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.apply(color: room.color()),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ] +
                      room.devices
                          .where(
                            (device) => device.type == DeviceType.timeshifter,
                          )
                          .map((device) {
                            return ListTile(
                              leading: Icon(device.type.iconData, size: 24),
                              title: Text(device.deviceId),
                              onTap: () {
                                Navigator.pop(context, {
                                  "device": device,
                                  "room": room,
                                });
                              },
                            );
                          })
                          .toList() +
                      <Widget>[Divider()],
                );
              }).toList(),
        ),
      ),
    );
  }
}
