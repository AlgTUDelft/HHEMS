import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/page/devices_page.dart';

/// A widget that displays the name and the list of devices of a [Room].
/// 
/// The devices are all displayed using their associated [Widget]s.
class EditRoom extends StatefulWidget {
  final Room room;

  const EditRoom({super.key, required this.room});

  @override
  State<EditRoom> createState() => _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  /// Builds the widget tree for displaying the [Room].
  ///
  /// The method constructs a [Scaffold] which contains:
  /// - An [AppBar] displaying the name of the room.
  /// - A [ListView] displaying all the [Device]s assigned to the room with their associated [Widget]s.
  ///   If the room has no [Device]s, it displays a centered message informing the user of this fact.
  /// - A [FloatingActionButton] that opens a dialog to confirm that the user intends to delete the room.
  ///   If confirmed, the room is removed from the [AppState]'s list of rooms.
  /// - A [FloatingActionButton] that opens a dialog that allows the user to edit the room's details.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.room.name)),
      body:
          widget.room.devices.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${context.l10n.noDevicesAddedToThisRoomYet}!",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonal(onPressed: editRoomDialog, child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.add), SizedBox(width: 10,), Text(context.l10n.editRoomDevices)],
                      ),
                    ))
                  ],
                ),
              )
              : Stack(
                children: [
                  ListenableBuilder(
                    listenable: AppState(),
                    builder: (context, child) => ListView(
                      padding: const EdgeInsets.all(10),
                      children:
                          widget.room.devices.asMap().entries.expand((e) {
                            final isLast = e.key == AppState().devices.length - 1;
                            return [
                              e.value.widget,
                              if (!isLast)
                                SizedBox(height: 16)
                              else
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                ),
                            ];
                          }).toList(),
                    ),
                  ),
                ],
              ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.room == AppState().othersRoom(context) ? [] : [
          FloatingActionButton(
            heroTag: 'deleteButton',
            onPressed: () async {
              final confirm = await deleteRoomDialog();
              if (confirm) AppState().removeRoom(widget.room);
            },
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
          ),
          SizedBox(width: 16),
          Flexible(
            child: FloatingActionButton.extended(
              heroTag: 'editButton',
              onPressed: () {
                editRoomDialog();
              },
              label: Text(context.l10n.editRoomDevices, overflow: TextOverflow.ellipsis,),
              icon: Icon(Icons.edit),
              
            ),
          ),
        ],
      ),
    );
  }

  /// Displays an [AlertDialog] asking the user to confirm their decision to delete the current [Room].
  ///
  /// The [AlertDialog] contains 'Cancel' and 'Delete' [TextButton]s. If the user selects 'Delete', the
  /// method returns 'true', and navigates back to the home screen. If the user selects 'Cancel' or they
  /// dismiss the dialog, the method returns 'false'.
  Future<bool> deleteRoomDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(context.l10n.confirmDeletion),
              content: Text(
                "${context.l10n.areYouSureYouWantToDeleteThisRoom}?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(
                          context,
                        ).colorScheme.onErrorContainer,
                  ),
                  child: Text(
                    context.l10n.delete,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Displays a dialog that allows the user to edit the [Room]'s properties.
  ///
  /// The dialog includes widgets to modify:
  /// - The room's name via a [TextField].
  /// - The room's type via a [DropdownButton] listing all [RoomType]s.
  /// - The [Device]s in the room via a scrollable [ListView] of [CheckboxListTile] widgets.
  /// - A 'Save Changes' [TextButton] which updates the room's name, type and [Device]s
  ///   using the [editRoom] method from [AppState] if they have changed and then closes the dialog.
  /// - A 'Cancel' [TextButton] which makes no changes and closes the dialog.
  void editRoomDialog() async {
    String newName = "";
    RoomType? newType = widget.room.type;
    List<Device> newDevices = widget.room.devices;
    List<Device> availableDevices = AppState().devices;
    List<bool> managed = List.filled(availableDevices.length, false);
    for (int i = 0; i < availableDevices.length; i++) {
      if (widget.room.devices.contains(availableDevices[i])) {
        managed[i] = true;
      }
    }
    final TextEditingController nameController = TextEditingController(
      text: widget.room.name,
    );

    ScrollController scrollController = ScrollController();
    final editedRoom =
        await showDialog<Room>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.l10n.editRoom(widget.room.name),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontSize: 25),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 16,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      context.l10n.type,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width /
                                          12,
                                    ),
                                    Expanded(
                                      child: DropdownButton<RoomType>(
                                        dropdownColor:
                                            Theme.of(context).cardTheme.color,
                                        isExpanded: true,
                                        items:
                                            RoomType.values.map((e) {
                                              return DropdownMenuItem<RoomType>(
                                                value: e,
                                                child: Text(
                                                  e.localizedName(context.l10n),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            newType = value;
                                          });
                                        },
                                        value: newType,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      context.l10n.name,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width /
                                          16,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: nameController,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  context.l10n.devices,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  width: MediaQuery.of(context).size.width,
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    controller: scrollController,
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: availableDevices.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == availableDevices.length) {
                                          return Column(
                                            children: [
                                              SizedBox(height: 20),
                                              Text(context.l10n.cantFindYourDevice),
                                              SizedBox(height: 10),
                                              OutlinedButton(
                                                onPressed: () async {
                                                  await addDeviceDialog(context);
                                                  if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                  editRoomDialog();
                                                  }
                                                },
                                                child: Text(context.l10n.manageDevices),
                                              ),
                                            ],
                                          );
                                        }
                                        final d = availableDevices[index];
                                        return CheckboxListTile(
                                          title: Text(
                                            d.type.localizedName(context.l10n),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "${context.l10n.device} ID: ${d.deviceId}",
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                          ),
                                          secondary: Column(
                                            children: [
                                              SizedBox(height: 20),
                                              Icon(d.type.iconData),
                                            ],
                                          ),
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
                                SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pop(widget.room);
                                        },
                                        child: Text(context.l10n.cancel),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: FilledButton(
                                        onPressed: () {
                                          newName = nameController.text.trim();
                                          if (newType != null &&
                                              newName.isNotEmpty) {
                                            newDevices =
                                                availableDevices
                                                    .asMap()
                                                    .entries
                                                    .where(
                                                      (entry) =>
                                                          managed[entry.key],
                                                    )
                                                    .map((entry) => entry.value)
                                                    .toList();
                                            Navigator.of(context).pop(
                                              Room(
                                                name: newName,
                                                type: newType!,
                                                devices: newDevices,
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(context.l10n.saveChanges),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ) ??
        widget.room;

    if (editedRoom != widget.room) {
      if (newName.isNotEmpty) {
        setState(() {
          AppState().editRoom(
            widget.room,
            newName,
            widget.room.type,
            widget.room.devices,
          );
        });
      }
      if (newType != null) {
        setState(() {
          AppState().editRoom(
            widget.room,
            widget.room.name,
            newType!,
            widget.room.devices,
          );
        });
      }
      if (!ListEquality().equals(newDevices, widget.room.devices)) {
        setState(() {
          AppState().editRoom(
            widget.room,
            widget.room.name,
            widget.room.type,
            newDevices,
          );
        });
      }
    }
  }
}
