import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/l10n/app_localizations.dart';

import 'device.dart';

/// Room types, denote which names and icons should be used on the home page.
enum RoomType {
  bedroom,
  kitchen,
  livingRoom,
  bathroom,
  garden,
  washingRoom,
  others,
}

extension RoomTypeExtension on RoomType {
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      RoomType.bedroom => l10n.bedroom,
      RoomType.kitchen => l10n.kitchen,
      RoomType.livingRoom => l10n.livingRoom,
      RoomType.bathroom => l10n.bathroom,
      RoomType.garden => l10n.garden,
      RoomType.washingRoom => l10n.washingRoom,
      RoomType.others => l10n.others,
    };
  }
}

class Room {
  RoomType type;
  String name;
  List<Device> devices;

  /// Constructs a new [Room].
  ///
  /// [name] is what the room is called throughout the app.
  /// The room's icon and color are based on its [type].
  /// [devices] are the devices the user has assigned to this room.
  Room({required this.type, required this.name, required this.devices});

  IconData icon() {
    return switch (type) {
      RoomType.bedroom => Icons.bed_outlined,
      RoomType.kitchen => Icons.kitchen_outlined,
      RoomType.livingRoom => Icons.weekend_outlined,
      RoomType.bathroom => Icons.bathtub_outlined,
      RoomType.garden => Icons.park_outlined,
      RoomType.washingRoom => Icons.local_laundry_service_outlined,
      RoomType.others => Icons.devices_outlined,
    };
  }

  Color color() {
    return switch (type) {
      RoomType.bedroom => Colors.deepPurple,
      RoomType.kitchen => Colors.blueGrey,
      RoomType.livingRoom => Colors.orange,
      RoomType.bathroom => Colors.blue,
      RoomType.garden => Colors.green,
      RoomType.washingRoom => Colors.red,
      RoomType.others => Colors.grey,
    };
  }

  @override
  int get hashCode => Object.hash(type, name, ListEquality().hash(devices));

  @override
  bool operator ==(Object other) {
    return other is Room &&
        other.type == type &&
        other.name == name &&
        ListEquality().equals(other.devices, devices);
  }

  Room.fromJson(Map<String, dynamic> json) :
    name = json['name'] as String,
      devices = (json['devices'] as List<dynamic>).map(
        (j) => Device.fromJson(j as Map<String, dynamic>),
      ).toList(),
    type = switch(json['type']) {
      'bedroom' => RoomType.bedroom,
      'kitchen' => RoomType.kitchen,
      'livingRoom' => RoomType.livingRoom,
      'bathroom' => RoomType.bathroom,
      'garden' => RoomType.garden,
      'washingRoom' => RoomType.washingRoom,
      'others' => RoomType.others,
      _ => throw FormatException('Invalid room type'),
    };

  Map<String, dynamic> toJson() => {
    'name': name,
    'devices': devices.map((d) => d.toJson()).toList(),
    'type': switch (type) {
      RoomType.bedroom => 'bedroom',
      RoomType.kitchen => 'kitchen',
      RoomType.livingRoom => 'livingRoom',
      RoomType.bathroom => 'bathroom',
      RoomType.garden => 'garden',
      RoomType.washingRoom => 'washingRoom',
      RoomType.others => 'others',
    },
  };
}
