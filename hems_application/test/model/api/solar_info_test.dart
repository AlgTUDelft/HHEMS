import 'dart:convert';

import 'package:hems_app/model/api/solar_info.dart';
import 'package:test/test.dart';

void main() {
  final solInfo1 = SolarInfo(241.0);
  final solInfo2 = SolarInfo(241.0);
  final solInfo3 = SolarInfo(303.0);

  final json1 = jsonDecode('''{
    "consumption": 303.0
  }''');
  final json2 = jsonDecode('''{
    "consumption": 303
  }''');

  group('== operator tests', () {
    test('Is equal', () {
      expect(solInfo1, equals(solInfo2));
    });
    test('Is not equal', () {
      expect(solInfo1, isNot(equals(solInfo3)));
    });
  });

  test('hashCode test', () {
    expect(solInfo1.hashCode, equals(solInfo1.hashCode));
    expect(solInfo1.hashCode, equals(solInfo2.hashCode));
    expect(solInfo2.hashCode, equals(solInfo2.hashCode));
  });

  group('fromJson tests', () {
    test('fromJson works with doubles', () {
      expect(SolarInfo.fromJson(json1), solInfo3);
    });
    test('fromJson works with integers', () {
      expect(SolarInfo.fromJson(json2), solInfo3);
    });
  });
}
