import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/service/device_service.dart';
import 'package:hems_app/state/app_state.dart';

/// A widget that displays all of the [Device]s that the user has added to the app.
/// 
/// Each device is displayed using their associated [Widget].
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => DevicesPageState();
}

class DevicesPageState extends State<DevicesPage> {
  /// Builds the widget tree.
  ///
  /// If there are no [Device]s present in the [AppState], a centered message is displayed informing
  /// the user of this fact. Otherwise, a [ListView] of the corresponding [Widget] for each device
  /// is displayed.
  ///
  /// A [FloatingActionButton] is always positioned at the bottom right corner of the screen.
  /// When pressed, it calls the [addDeviceDialog] method to allow adding new devices.
  ///
  /// A [Stack] is used to overlay the button above either the centered message or the scrollable
  /// device list.
  @override
  Widget build(BuildContext context) {
    return AppState().devices.isEmpty
        ? Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${context.l10n.noDevicesAddedYet}!",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(onPressed: () async => {await addDeviceDialog(context), setState(() {}),}, 
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.add), SizedBox(width: 10,), Text(context.l10n.manageDevices)],
                    ),
                  ))
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton.extended(
                onPressed: () async => {
                  await addDeviceDialog(context),
                  setState(() {}),
                },
                icon: Icon(Icons.assignment),
                label: Text(context.l10n.manageDevices),
              ),
            ),
          ],
        )
        : Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ...AppState().devices.asMap().entries.expand((e) {
                  final isLast = e.key == AppState().devices.length - 1;
                  return [
                    e.value.widget,
                    if (!isLast) const SizedBox(height: 16),
                  ];
                }),
                SizedBox(height: 64),
              ],
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton.extended(
                onPressed: () async => {
                  await addDeviceDialog(context),
                  setState(() {}),
                },
                icon: Icon(Icons.assignment),
                label: Text(context.l10n.manageDevices),
              ),
            ),
          ],
        );
  }

  
}

  /// Shows a [AlertDialog] containing the [Device]s available in the backend.
  /// 
  /// Devices can be marked to be available as managed devices in the app.
  /// Currently the endpoint to get all devices is mocked in the [DeviceService] class.
  Future<void> addDeviceDialog(BuildContext context) async {
    List<Device> availableDevices = await DeviceService().getDevices().fold(
      (left) => left,
      (right) => [],
    );
    List<bool> managed = List.filled(availableDevices.length, false);
    for (int i = 0; i < availableDevices.length; i++) {
      if (AppState().devices.contains(availableDevices[i])) {
        managed[i] = true;
      }
    }
    ScrollController scrollController = ScrollController();
    bool choice = false;

    if (context.mounted) {
      choice =
          await showDialog<bool>(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text(context.l10n.addOrRemoveManagedDevices),
                    content: SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width,
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: availableDevices.length,
                          itemBuilder: (context, index) {
                            Device d = availableDevices[index];
                            return CheckboxListTile(
                              title: Text(
                                d.type.localizedName(context.l10n),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${context.l10n.device} ID: ${d.deviceId}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              secondary: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Icon(d.type.iconData),
                                ],
                              ),
                              isThreeLine: true,
                              value: managed[index],
                              onChanged: (value) {
                                setState(() {
                                  if (value != null) {
                                    managed[index] = value;
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(context.l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(context.l10n.done),
                      ),
                    ],
                  );
                },
              );
            },
          ) ??
          false;
    }

    if (choice) {
      AppState().devices =
            availableDevices
                .asMap()
                .entries
                .where((entry) => managed[entry.key])
                .map((entry) => entry.value)
                .toList();

      List<Device> currentDevices = AppState().devices;
      for (Room r in AppState().rooms) {
        List<Device> roomDevices = r.devices;
        List<Device> newRoomDevices = [];
        for (Device d in roomDevices) {
          if (currentDevices.contains(d)) newRoomDevices.add(d);
        }
        AppState().editRoom(r, r.name, r.type, newRoomDevices);
      }
    }
  }