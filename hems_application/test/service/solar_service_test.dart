import 'dart:convert';

import 'package:hems_app/model/api/solar_info.dart';
import 'package:hems_app/service/solar_service.dart';
import 'package:test/test.dart';

void main() {
  final solarService = SolarService();
  final solarInfo = SolarInfo(241.0);

  final json1 = jsonDecode('''{
    "consumption": 241.0
  }''');
  final json2 = jsonDecode('{"key": "value"}');

  group('jsonSolarInfo Tests', () {
    test('Valid json successful', () {
      final result = solarService.jsonToSolarInfo(json1);

      expect(result.isLeft, true);
      expect(result.left, solarInfo);
    });
    test('Invalid json unsuccessful', () {
      final result = solarService.jsonToSolarInfo(json2);

      expect(result.isRight, true);
    });
  });

  // Integration tests expect the basic configuration provided by the client in the backend.
  group(
    'Integration tests',
    () {
      test('getSolarInfo works', () async {
        final result = await solarService.getSolarInfo(0, 0);
        expect(result.isLeft, true);
      });
      test('setState works', () async {
        final result1 = await solarService.setState(0, 0, false);
        expect(result1.isLeft, true);

        final result2 = await solarService.setState(0, 0, true);
        expect(result2.isLeft, true);
      });
    },
    tags: ['integration'], 
    skip:
        const bool.hasEnvironment('HEMS_URL')
            ? false
            : 'HEMS_URL not set, skipping integration test',
  );
}
