import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/service/device_service.dart';
import 'package:path_provider/path_provider.dart';

/// A singleton class that manages the global application state for rooms, devices.
///
/// It extends [ChangeNotifier] to allow widgets to listen for changes in the state and update
/// accordingly.
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();

  final _deviceService = DeviceService();

  List<Room> _rooms = [];
  List<Device> _devices = [];
  bool _isSolarEnabled = true;

  AppState._internal();

  /// A singleton class that manages the global application state for rooms and devices.
  ///
  /// It extends [ChangeNotifier] to allow widgets to listen for changes in the state and update
  /// accordingly.
  factory AppState() {
    return _instance;
  }

  /// Initializes app state from the persistence file.
  ///
  /// The file that is used for persistence is app_state.json inside 
  /// platform specific app documents directory.
  /// Returns a future that can be awaited to ensure initialization is finished
  Future<void> initFromFile() async {
    try {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocumentsDir.path}/app_state.json');
      final contents = await file.readAsString();

      await initFromJson(jsonDecode(contents));
    } catch (_) {}
  }

  /// Writes the app state json to the persistence file
  ///
  /// The file that is used for persistence is app_state.json inside 
  /// platform specific app documents directory.
  /// Returns a future that can be awaited to ensure writing is finished
  Future<void> dumpStateToFile() async {
    try {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocumentsDir.path}/app_state.json');

      await file.writeAsString(jsonEncode(toJson()));
    } catch (_) {}
  }

  /// Initializes the app state from a [json].
  ///
  /// The [json] that is used for initialization has the same format
  /// as [toJson] generates.
  /// This method ignores devices that are not present in the current backend
  /// Returns a future that can be awaited to ensure initlization is finished
  Future<void> initFromJson(Map<String, dynamic> json) async {
    final availableDevices = (await _deviceService.getDevices()).fold(
      (left) => left,
      (right) => [],
    );
    _devices =
        (json['devices'] as List<dynamic>)
            .map((j) => Device.fromJson(j as Map<String, dynamic>))
            .where((d) => availableDevices.contains(d))
            .toList();
    _rooms =
        (json['rooms'] as List<dynamic>)
            .map((j) => Room.fromJson(j as Map<String, dynamic>))
            .toList();

    for (Room room in _rooms) {
      room.devices = room.devices.where((d) => _devices.contains(d)).toList();
    }

    _isSolarEnabled = json['is_solar_enabled'] as bool;

    notifyListeners();
  }

  /// Creates a json that can be used to restore the current state using [initFromJson]
  Map<String, dynamic> toJson() => {
    'rooms': _rooms.map((r) => r.toJson()).toList(),
    'devices': _devices.map((d) => d.toJson()).toList(),
    'is_solar_enabled': _isSolarEnabled,
  };

  /// Returns the rooms the user has created.
  List<Room> get rooms => List.unmodifiable(_rooms);

  /// Returns the devices the user is actively managing in the app.
  List<Device> get devices => List.unmodifiable(_devices);

  /// Returns whether solar is enabled
  bool get isSolarEnabled => _isSolarEnabled;

  /// Adds a room to the list of rooms.
  ///
  /// Also notifies the listeners and saves the new state.
  void addRoom(Room r) {
    _rooms.add(r);
    notifyListeners();
    dumpStateToFile();
  }

  /// Removes a room from the list of rooms.
  ///
  /// Also notifies the listeners and saves the new state.
  void removeRoom(Room r) {
    _rooms.remove(r);
    notifyListeners();
    dumpStateToFile();
  }

  /// Changes the details of a room
  ///
  /// Also notifies the listeners and saves the new state.
  void editRoom(Room r, String name, RoomType roomType, List<Device> devices) {
    r.name = name;
    r.type = roomType;
    r.devices = devices;
    notifyListeners();
    dumpStateToFile();
  }

  /// Adds a device to the list of devices.
  ///
  /// Also notifies the listeners and saves the new state.
  void addDevice(Device d) {
    _devices.add(d);
    notifyListeners();
    dumpStateToFile();
  }

  /// Removes a device from the list of devices.
  ///
  /// Also notifies the listeners and saves the new state.
  void removeDevice(Device d) {
    _devices.remove(d);
    notifyListeners();
    dumpStateToFile();
  }

  /// Sets the list of rooms
  ///
  /// Also notifies the listeners and saves the new state.
  set rooms(List<Room> rooms) {
    _rooms = rooms;
    notifyListeners();
    dumpStateToFile();
  }

  /// Sets the list of devices
  ///
  /// Also notifies the listeners and saves the new state.
  set devices(List<Device> devices) {
    _devices = devices;
    notifyListeners();
    dumpStateToFile();
  }

  /// Sets whether solar is enabled.
  ///
  /// Also notifies the listeners and saves the new state.
  set isSolarEnabled(bool newEnabled) {
    _isSolarEnabled = newEnabled;
    notifyListeners();
    dumpStateToFile();
  }

  /// Returns a [Room] with all the [Device]'s that are not assigned to any room.
  Room othersRoom(BuildContext context) {
    List<Device> listedDevices = [];
    for (final room in rooms) {
      listedDevices.addAll(room.devices);
    }
    return Room(
      name: context.l10n.others,
      type: RoomType.others,
      devices:
          AppState().devices
              .where((device) => !listedDevices.contains(device))
              .toList(),
    );
  }
}
