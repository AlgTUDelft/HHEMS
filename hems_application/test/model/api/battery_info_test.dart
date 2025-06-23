import 'dart:convert';

import 'package:hems_app/model/api/battery_info.dart';
import 'package:hems_app/model/api/battery_status.dart';
import 'package:test/test.dart';

void main() {
  final batInfo1 = BatteryInfo(12000, 1347, 3700, 3700, 5285.25, BatteryStatus.discharging);
  final batInfo2 = BatteryInfo(12000, 1347, 3700, 3700, 5285.25, BatteryStatus.discharging);
  final batInfo3 = BatteryInfo(12000, 1347, 3700, 3700, 5285.25, BatteryStatus.discharging, 10000);
  final batInfo4 = BatteryInfo(12000, 1347, 3700, 3700, 5285.25, BatteryStatus.discharging, 10000);
  final batInfo5 = BatteryInfo(12000, 1347, 3700, 3700, 5285.25, BatteryStatus.discharging, 11000);
  final batInfo6 = BatteryInfo(10000, 1347, 3700, 3700, 5285.25, BatteryStatus.discharging);
  final batInfo7 = BatteryInfo(12000, 1500, 3700, 3700, 5285.25, BatteryStatus.discharging);
  final batInfo8 = BatteryInfo(12000, 1347, 4000, 3700, 5285.25, BatteryStatus.discharging);
  final batInfo9 = BatteryInfo(12000, 1347, 3700, 4000, 5285.25, BatteryStatus.discharging);
  final batInfo10 = BatteryInfo(12000, 1347, 3700, 3700, 5400.47, BatteryStatus.discharging);
  final batInfo11 = BatteryInfo(12000, 1347, 3700, 3700, 5285.25, BatteryStatus.charging);

  final json1 = jsonDecode('''{
  "capacity": 12000.0,
  "max_charge": 3700.0,
  "max_discharge": 3700.0,
  "state_of_charge": 5285.25,
  "target_soc": null,
  "status": "Discharging",
  "consumption": 1347.0
}''');
  final json2 = jsonDecode('''{
  "capacity": 12000.0,
  "max_charge": 3700.0,
  "max_discharge": 3700.0,
  "state_of_charge": 5285.25,
  "target_soc": 10000.0,
  "status": "Discharging",
  "consumption": 1347.0
}''');
  final json3 = jsonDecode('''{
  "capacity": 12000,
  "max_charge": 3700,
  "max_discharge": 3700,
  "state_of_charge": 5285.25,
  "target_soc": 10000,
  "status": "Discharging",
  "consumption": 1347
}''');
  final json4 = jsonDecode('''{
  "capacity": 12000.0,
  "max_charge": 3700.0,
  "max_discharge": 3700.0,
  "state_of_charge": 5285.25,
  "target_soc": null,
  "status": "NotAStatus",
  "consumption": 1347.0
}''');

  group('== operator tests', () {
    test('Equality true without target soc', () {
      expect(batInfo1, equals(batInfo1));
      expect(batInfo1, equals(batInfo2));
      expect(batInfo2, equals(batInfo2));
    });
    test('Equality true with target soc', () {
      expect(batInfo3, equals(batInfo3));
      expect(batInfo3, equals(batInfo4));
      expect(batInfo4, equals(batInfo4));
    });
    test('Equality considers target soc', () {
      expect(batInfo1, isNot(equals(batInfo3)));
      expect(batInfo3, isNot(equals(batInfo5)));
    });
    test('Equality considers capacity', () {
      expect(batInfo1, isNot(equals(batInfo6)));
    });
    test('Equality considers consumption', () {
      expect(batInfo1, isNot(equals(batInfo7)));
    });
    test('Equality considers maxCharge', () {
      expect(batInfo1, isNot(equals(batInfo8)));
    });
    test('Equality considers maxDischarge', () {
      expect(batInfo1, isNot(equals(batInfo9)));
    });
    test('Equality considers stateOfCharge', () {
      expect(batInfo1, isNot(equals(batInfo10)));
    });
    test('Equality considers status', () {
      expect(batInfo1, isNot(equals(batInfo11)));
    });
  });

  group('Hashcode tests', () {
    test('Hashcode consistent with equality without target soc', () {
      expect(batInfo1.hashCode, equals(batInfo1.hashCode));
      expect(batInfo1.hashCode, equals(batInfo2.hashCode));
      expect(batInfo2.hashCode, equals(batInfo2.hashCode));
    });
    test('Hashcode consistent with equality with target soc', () {
      expect(batInfo3.hashCode, equals(batInfo3.hashCode));
      expect(batInfo3.hashCode, equals(batInfo4.hashCode));
      expect(batInfo4.hashCode, equals(batInfo4.hashCode));
    });
  });

  group('fromJson tests', () {
    test('fromJson works with null target soc', () {
      expect(BatteryInfo.fromJson(json1), batInfo1);
    });
    test('fromJson works with target soc', () {
      expect(BatteryInfo.fromJson(json2), batInfo3);
    });
    test('fromJson works with integer values', () {
      expect(BatteryInfo.fromJson(json3), batInfo3);
    });
    test('fromJson throws exception for invalid status', () {
      expect(() => BatteryInfo.fromJson(json4), throwsFormatException);
    });
  });
}
