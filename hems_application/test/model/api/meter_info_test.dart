import 'dart:convert';

import 'package:hems_app/model/api/meter_info.dart';
import 'package:test/test.dart';

void main() {
  final MeterInfo meterInfo1 = MeterInfo(120.5, 350.0, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo1B = MeterInfo(120.0, 350.0, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo2 = MeterInfo(120.5, 350.0, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo3 = MeterInfo(null, 350.0, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo3B = MeterInfo(null, 350.0, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo4 = MeterInfo(120.5, null, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo4B = MeterInfo(120.5, null, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo5 = MeterInfo(null, null, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo5B = MeterInfo(null, null, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo6 = MeterInfo(201.5, 350.0, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo7 = MeterInfo(120.5, 590.0, 1, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo8 = MeterInfo(120.5, 350.0, 2, 101, 5500.0, 12000.0);
  final MeterInfo meterInfo9 = MeterInfo(120.5, 350.0, 1, 123, 5500.0, 12000.0);
  final MeterInfo meterInfo10 = MeterInfo(120.5, 350.0, 1, 101, 7500.0, 12000.0);
  final MeterInfo meterInfo11 = MeterInfo(120.5, 350.0, 1, 101, 5500.0, 20000.0);

  final json1 = jsonDecode('''{
    "current_export": 120.5,
    "current_import": 350.0,
    "house_id": 1,
    "meter_id": 101,
    "total_export": 5500.0,
    "total_import": 12000.0
  }''');
  final json2 = jsonDecode('''{
    "current_export": null,
    "current_import": 350.0,
    "house_id": 1,
    "meter_id": 101,
    "total_export": 5500.0,
    "total_import": 12000.0
  }''');
  final json3 = jsonDecode('''{
    "current_export": 120.5,
    "current_import": null,
    "house_id": 1,
    "meter_id": 101,
    "total_export": 5500.0,
    "total_import": 12000.0
  }''');
  final json4 = jsonDecode('''{
    "current_export": null,
    "current_import": null,
    "house_id": 1,
    "meter_id": 101,
    "total_export": 5500.0,
    "total_import": 12000.0
  }''');
  final json5 = jsonDecode('''{
    "current_export": 120,
    "current_import": 350,
    "house_id": 1,
    "meter_id": 101,
    "total_export": 5500,
    "total_import": 12000
  }''');

  group('== operator tests', () {
    test('Is equal', () {
      expect(meterInfo1, equals(meterInfo2));
    });
    test('Is not equal, currentExport null', () {
      expect(meterInfo1, isNot(equals(meterInfo3)));
    });
    test('Is not equal, currentImport null', () {
      expect(meterInfo1, isNot(equals(meterInfo4)));
    });
    test('Is not equal, both null', () {
      expect(meterInfo1, isNot(equals(meterInfo5)));
    });
    test('Is not equal, currentExport', () {
      expect(meterInfo1, isNot(equals(meterInfo6)));
    });
    test('Is not equal, currentImport', () {
      expect(meterInfo1, isNot(equals(meterInfo7)));
    });
    test('Is not equal, houseId', () {
      expect(meterInfo1, isNot(equals(meterInfo8)));
    });
    test('Is not equal, meterId', () {
      expect(meterInfo1, isNot(equals(meterInfo9)));
    });
    test('Is not equal, totalExport', () {
      expect(meterInfo1, isNot(equals(meterInfo10)));
    });
    test('Is not equal, totalImport', () {
      expect(meterInfo1, isNot(equals(meterInfo11)));
    });
  });

  group('hashCode tests', () {
    test('Is equal without nulls', () {
      expect(meterInfo1.hashCode, equals(meterInfo1.hashCode));
      expect(meterInfo1.hashCode, equals(meterInfo2.hashCode));
      expect(meterInfo2.hashCode, equals(meterInfo2.hashCode));
    });
    test('Is equal with nulls', () {
      expect(meterInfo3.hashCode, equals(meterInfo3.hashCode));
      expect(meterInfo3.hashCode, equals(meterInfo3B.hashCode));
      expect(meterInfo4.hashCode, equals(meterInfo4.hashCode));
      expect(meterInfo4.hashCode, equals(meterInfo4B.hashCode));
      expect(meterInfo5.hashCode, equals(meterInfo5.hashCode));
      expect(meterInfo5.hashCode, equals(meterInfo5B.hashCode));
    });
  });

  group('fromJson tests', () {
    test('fromJson works with no nulls', () {
      expect(MeterInfo.fromJson(json1), meterInfo1);
    });
    test('fromJson works with currentExport null', () {
      expect(MeterInfo.fromJson(json2), meterInfo3);
    });
    test('fromJson works with currentImport null', () {
      expect(MeterInfo.fromJson(json3), meterInfo4);
    });
    test('fromJson works with both null', () {
      expect(MeterInfo.fromJson(json4), meterInfo5);
    });
    test('fromJson works with all integers', () {
      expect(MeterInfo.fromJson(json5), meterInfo1B);
    });
  });
}
