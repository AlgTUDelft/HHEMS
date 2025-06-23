import 'dart:convert';

import 'package:hems_app/model/api/battery_info.dart';
import 'package:hems_app/model/api/battery_status.dart';
import 'package:hems_app/service/battery_service.dart';
import 'package:test/test.dart';

void main() {
  final batteryService = BatteryService();

  final batInfo = BatteryInfo(
    12000,
    1347,
    3700,
    3700,
    5285.25,
    BatteryStatus.discharging,
  );

  final json1 = jsonDecode('''{
  "capacity": 12000.0,
  "max_charge": 3700.0,
  "max_discharge": 3700.0,
  "state_of_charge": 5285.25,
  "target_soc": null,
  "status": "Discharging",
  "consumption": 1347.0
}''');
  final json2 = jsonDecode('{"key": "value"}');

  group('jsonBatteryInfo Tests', () {
    test('Valid json successful', () {
      final result = batteryService.jsonToBatteryInfo(json1);

      expect(result.isLeft, true);
      expect(result.left, batInfo);
    });
    test('Invalid json unsuccessful', () {
      final result = batteryService.jsonToBatteryInfo(json2);

      expect(result.isRight, true);
    });
  });

  // Integration tests expect the basic configuration provided by the client in the backend.
  group(
    'Integration tests',
    () {
      test('getBatteryInfo works', () async {
        final result = await batteryService.getBatteryInfo(0, 0);
        expect(result.isLeft, true);
      });
      test('(un)setTargetSOC works', () async {
        final result1 = await batteryService.unsetTargetSOC(0, 0);

        expect(result1.isLeft, true);
        expect(result1.left.targetSoc, null);

        final result2 = await batteryService.setTargetSOC(0, 0, 10);

        expect(result2.isLeft, true);
        expect(result2.left.targetSoc, 10);

        final result3 = await batteryService.unsetTargetSOC(0, 0);

        expect(result3.isLeft, true);
        expect(result3.left.targetSoc, null);
      });
    },
    tags: ['integration'], 
    skip:
        const bool.hasEnvironment('HEMS_URL')
            ? false
            : 'HEMS_URL not set, skipping integration test',
  );
}
