import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:test/test.dart';

void main() {
  final device1 = Device(
    houseId: 0,
    deviceId: 'DishWasher',
    type: DeviceType.timeshifter,
  );
  final device2 = Device(
    houseId: 0,
    deviceId: 'DishWasher',
    type: DeviceType.timeshifter,
  );
  final device3 = Device(
    houseId: 1,
    deviceId: 'DishWasher',
    type: DeviceType.timeshifter,
  );
  final device4 = Device(
    houseId: 0,
    deviceId: 'WashingMachine',
    type: DeviceType.timeshifter,
  );
  final device5 = Device(
    houseId: 0,
    deviceId: 'DishWasher',
    type: DeviceType.solar,
  );
  final device6 = Device(
    houseId: 0,
    deviceId: 'DishWasher',
    type: DeviceType.thermal,
  );
  final device7 = Device(
    houseId: 0,
    deviceId: 'DishWasher',
    type: DeviceType.meter,
  );
  final device8 = Device(
    houseId: 0,
    deviceId: 'DishWasher',
    type: DeviceType.battery,
  );
  final device9 = Device(
    houseId: 0,
    deviceId: 'DishWasher',
    type: DeviceType.haEntity,
  );

  final json1 = jsonDecode('''{
  "house_id": 0,
  "device_id": "DishWasher",
  "type": "timeshifter"
}''');
  final json2 = jsonDecode('''{
  "house_id": 0,
  "device_id": "DishWasher",
  "type": "solar"
}''');
  final json3 = jsonDecode('''{
  "house_id": 0,
  "device_id": "DishWasher",
  "type": "thermal"
}''');
  final json4 = jsonDecode('''{
  "house_id": 0,
  "device_id": "DishWasher",
  "type": "meter"
}''');
  final json5 = jsonDecode('''{
  "house_id": 0,
  "device_id": "DishWasher",
  "type": "battery"
}''');
  final json6 = jsonDecode('''{
  "house_id": 0,
  "device_id": "DishWasher",
  "type": "haEntity"
}''');
  final json7 = jsonDecode('''{
  "house_id": 0,
  "device_id": "DishWasher",
  "type": "Invalid"
}''');

  group('== operator tests', () {
    test('Equality true', () {
      expect(device1, equals(device1));
      expect(device1, equals(device2));
    });
    test('Equality considers houseId', () {
      expect(device1, isNot(equals(device3)));
    });
    test('Equality considers deviceId', () {
      expect(device1, isNot(equals(device4)));
    });
    test('Equality considers type', () {
      expect(device1, isNot(equals(device5)));
      expect(device1, isNot(equals(device6)));
      expect(device1, isNot(equals(device7)));
      expect(device1, isNot(equals(device8)));
      expect(device1, isNot(equals(device9)));
    });
    test('Not equals different type', () {
      expect(device1, isNot(equals('')));
    });
  });

  group('Hashcode tests', () {
    test('Hashcode consistent with equality', () {
      expect(device1.hashCode, equals(device1.hashCode));
      expect(device1.hashCode, equals(device2.hashCode));
    });
  });

  group('DeviceType tests', () {
    test('name is total', () {
      expect(device1.type.name, TypeMatcher<String>());
      expect(device5.type.name, TypeMatcher<String>());
      expect(device6.type.name, TypeMatcher<String>());
      expect(device7.type.name, TypeMatcher<String>());
      expect(device8.type.name, TypeMatcher<String>());
      expect(device9.type.name, TypeMatcher<String>());
    });
    test('iconData is total', () {
      expect(device1.type.iconData, TypeMatcher<IconData>());
      expect(device5.type.iconData, TypeMatcher<IconData>());
      expect(device6.type.iconData, TypeMatcher<IconData>());
      expect(device7.type.iconData, TypeMatcher<IconData>());
      expect(device8.type.iconData, TypeMatcher<IconData>());
      expect(device9.type.iconData, TypeMatcher<IconData>());
    });
    test('widget is total', () {
      expect(device1.widget, TypeMatcher<Widget>());
      expect(device5.widget, TypeMatcher<Widget>());
      expect(device6.widget, TypeMatcher<Widget>());
      expect(device7.widget, TypeMatcher<Widget>());
      expect(device8.widget, TypeMatcher<Widget>());
      expect(device9.widget, TypeMatcher<Widget>());
    });
  });

  group('fromJson tests', () {
    test('fromJson works with valid type', () {
      expect(Device.fromJson(json1), device1);
      expect(Device.fromJson(json2), device5);
      expect(Device.fromJson(json3), device6);
      expect(Device.fromJson(json4), device7);
      expect(Device.fromJson(json5), device8);
      expect(Device.fromJson(json6), device9);
    });
    test('fromJson throws exception for invalid type', () {
      expect(() => Device.fromJson(json7), throwsFormatException);
    });
  });

  group('toJson tests', () {
    test('toJson works', () {
      expect(device1.toJson(), json1);
      expect(device5.toJson(), json2);
      expect(device6.toJson(), json3);
      expect(device7.toJson(), json4);
      expect(device8.toJson(), json5);
      expect(device9.toJson(), json6);
    });
  });
}
