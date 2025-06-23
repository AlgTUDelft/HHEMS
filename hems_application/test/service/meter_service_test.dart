import 'dart:convert';

import 'package:hems_app/model/api/meter_info.dart';
import 'package:hems_app/service/meter_service.dart';
import 'package:test/test.dart';

void main() {
  final meterService = MeterService();

  final meterInfo = MeterInfo(120.5, 350.0, 1, 101, 5500.0, 12000.0);

  final json1 = jsonDecode('''{
    "current_export": 120.5,
    "current_import": 350.0,
    "house_id": 1,
    "meter_id": 101,
    "total_export": 5500.0,
    "total_import": 12000.0
  }''');
  final json2 = jsonDecode('''{
    "current_export": 120.5,
    "current_import": null,
    "total_export": 5500.0,
    "total_import": 12000.0
  }''');

  group('jsonToMeterInfo Tests', () {
    test('Valid json successful', () {
      final result = meterService.jsonToMeterInfo(json1);

      expect(result.isLeft, true);
      expect(result.left, meterInfo);
    });
    test('Invalid json unsuccessful', () {
      final result = meterService.jsonToMeterInfo(json2);

      expect(result.isRight, true);
    });
  });

  // Integration tests expect the basic configuration provided by the client in the backend.
  group(
    'Integration tests',
    () {
      test('getMeterInfo works', () async {
        final result = await meterService.getMeterInfo(0, 0);
        expect(result.isLeft, true);
      });
    },
    tags: ['integration'], 
    skip:
        const bool.hasEnvironment('HEMS_URL')
            ? false
            : 'HEMS_URL not set, skipping integration test',
  );
}
