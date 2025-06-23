import 'dart:convert';

import 'package:hems_app/model/api/thermal_info.dart';
import 'package:hems_app/service/thermal_service.dart';
import 'package:test/test.dart';

void main() {
  final thermalService = ThermalService();

  final thermalInfo = ThermalInfo(849.0, 10.0, 50.0, 35.0);

  final json1 = jsonDecode('''{
    "consumption": 849.0,
    "current_temperature": 10.0,
    "heating_power": 50.0,
    "target_temperature": 35.0
  }''');
  final json2 = jsonDecode('''{
    "consumption": 609.0
  }''');
  final json3 = jsonDecode('''{
    "target_temperature": 30.0
  }''');
  final json4 = jsonDecode('''{
    "target_temperature": null
  }''');

  // Integration tests expect the basic configuration provided by the client in the backend.
  group('jsonToThermalInfo Tests', () {
    test('Valid json successful', () {
      final result = thermalService.jsonToThermalInfo(json1);

      expect(result.isLeft, true);
      expect(result.left, thermalInfo);
    });
    test('Invalid json unsuccessful', () {
      final result = thermalService.jsonToThermalInfo(json2);

      expect(result.isRight, true);
    });
  });

  group('jsonToTemperature Tests', () {
    test('Valid json successful', () {
      final result = thermalService.jsonToTemperature(json3);

      expect(result.isLeft, true);
      expect(result.left, 30.0);
    });
    test('Invalid json unsuccessful', () {
      final result = thermalService.jsonToTemperature(json4);

      expect(result.isRight, true);
    });
  });

  // Integration tests expect the basic configuration provided by the client in the backend.
  group(
    'Integration tests',
    () {
      test('getThermalInfo works', () async {
        final result1 = await thermalService.getThermalInfo(0, 0);
        expect(result1.isLeft, true);
      });
      test('setTargetTemperature works', () async {
        final result2 = await thermalService.setTargetTemperature(0, 0, 30.0);
        expect(result2.left, 30.0);
      });
    },
    tags: ['integration'],
    skip:
        const bool.hasEnvironment('HEMS_URL')
            ? false
            : 'HEMS_URL not set, skipping integration test',
  );
}
