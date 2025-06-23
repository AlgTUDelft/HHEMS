import 'dart:convert';

import 'package:hems_app/model/api/thermal_info.dart';
import 'package:test/test.dart';

void main() {
  final tInfo1 = ThermalInfo(552.0, 20.0, 30.0, 40.0);
  final tInfo2 = ThermalInfo(552.0, 20.0, 30.0, 40.0);
  final tInfo3 = ThermalInfo(650.0, 20.0, 30.0, 40.0);
  final tInfo4 = ThermalInfo(552.0, 60.0, 30.0, 40.0);
  final tInfo5 = ThermalInfo(552.0, 20.0, 80.0, 40.0);
  final tInfo6 = ThermalInfo(552.0, 20.0, 30.0, 90.0);
  final tInfo7 = ThermalInfo(849.0, 10.0, 50.0, 35.0);

  final json1 = jsonDecode('''{
    "consumption": 849.0,
    "current_temperature": 10.0,
    "heating_power": 50.0,
    "target_temperature": 35.0
  }''');
  final json2 = jsonDecode('''{
    "consumption": 849,
    "current_temperature": 10,
    "heating_power": 50,
    "target_temperature": 35
  }''');

  group('== operator tests', () {
    test('Is equal', () {
      expect(tInfo1, equals(tInfo2));
    });
    test('Is not equal, consumption', () {
      expect(tInfo1, isNot(equals(tInfo3)));
    });
    test('Is not equal, currentTemperature', () {
      expect(tInfo1, isNot(equals(tInfo4)));
    });
    test('Is not equal, heatingPower', () {
      expect(tInfo1, isNot(equals(tInfo5)));
    });
    test('Is not equal, targetTemperature', () {
      expect(tInfo1, isNot(equals(tInfo6)));
    });
  });

  test('hashCode test', () {
    expect(tInfo1.hashCode, equals(tInfo1.hashCode));
    expect(tInfo1.hashCode, equals(tInfo2.hashCode));
    expect(tInfo2.hashCode, equals(tInfo2.hashCode));
  });

  group('fromJson tests', () {
    test('fromJson works with doubles', () {
      expect(ThermalInfo.fromJson(json1), tInfo7);
    });
    test('fromJson works with integers', () {
      expect(ThermalInfo.fromJson(json2), tInfo7);
    });
  });
}
