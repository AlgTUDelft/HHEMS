import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:test/test.dart';

void main() {
  final room1 = Room(
    name: 'bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.bedroom,
  );
  final room2 = Room(
    name: 'bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.bedroom,
  );
  final room3 = Room(
    name: 'master bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.bedroom,
  );
  final room4 = Room(
    name: 'bedroom',
    devices: [Device(houseId: 1, deviceId: 'solar', type: DeviceType.solar)],
    type: RoomType.bedroom,
  );
  final room5 = Room(
    name: 'bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.kitchen,
  );
  final room6 = Room(
    name: 'bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.livingRoom,
  );
  final room7 = Room(
    name: 'bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.bathroom,
  );
  final room8 = Room(
    name: 'bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.garden,
  );
  final room9 = Room(
    name: 'bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.washingRoom,
  );
  final room10 = Room(
    name: 'bedroom',
    devices: [
      Device(houseId: 0, deviceId: 'dish', type: DeviceType.timeshifter),
    ],
    type: RoomType.others,
  );

  final json1 = jsonDecode('''{
  "name": "bedroom",
  "type": "bedroom",
  "devices": [
    {
      "house_id": 0,
      "device_id": "dish",
      "type": "timeshifter"
    }
  ]
}''');
  final json2 = jsonDecode('''{
  "name": "bedroom",
  "type": "kitchen",
  "devices": [
    {
      "house_id": 0,
      "device_id": "dish",
      "type": "timeshifter"
    }
  ]
}''');
  final json3 = jsonDecode('''{
  "name": "bedroom",
  "type": "livingRoom",
  "devices": [
    {
      "house_id": 0,
      "device_id": "dish",
      "type": "timeshifter"
    }
  ]
}''');
  final json4 = jsonDecode('''{
  "name": "bedroom",
  "type": "bathroom",
  "devices": [
    {
      "house_id": 0,
      "device_id": "dish",
      "type": "timeshifter"
    }
  ]
}''');
  final json5 = jsonDecode('''{
  "name": "bedroom",
  "type": "garden",
  "devices": [
    {
      "house_id": 0,
      "device_id": "dish",
      "type": "timeshifter"
    }
  ]
}''');
  final json6 = jsonDecode('''{
  "name": "bedroom",
  "type": "washingRoom",
  "devices": [
    {
      "house_id": 0,
      "device_id": "dish",
      "type": "timeshifter"
    }
  ]
}''');
  final json7 = jsonDecode('''{
  "name": "bedroom",
  "type": "others",
  "devices": [
    {
      "house_id": 0,
      "device_id": "dish",
      "type": "timeshifter"
    }
  ]
}''');
  final json8 = jsonDecode('''{
  "name": "bedroom",
  "type": "invalid",
  "devices": [
    {
      "house_id": 0,
      "device_id": "dish",
      "type": "timeshifter"
    }
  ]
}''');

  group('== operator tests', () {
    test('Equality true', () {
      expect(room1, equals(room1));
      expect(room1, equals(room2));
    });
    test('Equality considers type', () {
      expect(room1, isNot(equals(room3)));
    });
    test('Equality considers devices', () {
      expect(room1, isNot(equals(room4)));
    });
    test('Equality considers type', () {
      expect(room1, isNot(equals(room5)));
      expect(room1, isNot(equals(room6)));
      expect(room1, isNot(equals(room7)));
      expect(room1, isNot(equals(room8)));
      expect(room1, isNot(equals(room9)));
      expect(room1, isNot(equals(room10)));
    });
    test('Not equals different type', () {
      expect(room1, isNot(equals('')));
    });
  });

  group('Hashcode tests', () {
    test('Hashcode consistent with equality', () {
      expect(room1.hashCode, equals(room1.hashCode));
      expect(room1.hashCode, equals(room2.hashCode));
    });
  });

  group('Totality tests', () {
    test('name is total', () {
      expect(room1.type.name, TypeMatcher<String>());
      expect(room5.type.name, TypeMatcher<String>());
      expect(room6.type.name, TypeMatcher<String>());
      expect(room7.type.name, TypeMatcher<String>());
      expect(room8.type.name, TypeMatcher<String>());
      expect(room9.type.name, TypeMatcher<String>());
      expect(room10.type.name, TypeMatcher<String>());
    });
    test('icon is total', () {
      expect(room1.icon(), TypeMatcher<IconData>());
      expect(room5.icon(), TypeMatcher<IconData>());
      expect(room6.icon(), TypeMatcher<IconData>());
      expect(room7.icon(), TypeMatcher<IconData>());
      expect(room8.icon(), TypeMatcher<IconData>());
      expect(room9.icon(), TypeMatcher<IconData>());
      expect(room10.icon(), TypeMatcher<IconData>());
    });
    test('color is total', () {
      expect(room1.color(), TypeMatcher<Color>());
      expect(room5.color(), TypeMatcher<Color>());
      expect(room6.color(), TypeMatcher<Color>());
      expect(room7.color(), TypeMatcher<Color>());
      expect(room8.color(), TypeMatcher<Color>());
      expect(room9.color(), TypeMatcher<Color>());
      expect(room10.color(), TypeMatcher<Color>());
    });
  });

  group('fromJson tests', () {
    test('fromJson works with valid type', () {
      expect(Room.fromJson(json1), room1);
      expect(Room.fromJson(json2), room5);
      expect(Room.fromJson(json3), room6);
      expect(Room.fromJson(json4), room7);
      expect(Room.fromJson(json5), room8);
      expect(Room.fromJson(json6), room9);
      expect(Room.fromJson(json7), room10);
    });
    test('fromJson throws exception for invalid type', () {
      expect(() => Room.fromJson(json8), throwsFormatException);
    });
  });

  group('toJson tests', () {
    test('toJson works', () {
      expect(room1.toJson(), json1);
      expect(room5.toJson(), json2);
      expect(room6.toJson(), json3);
      expect(room7.toJson(), json4);
      expect(room8.toJson(), json5);
      expect(room9.toJson(), json6);
      expect(room10.toJson(), json7);
    });
  });
}
