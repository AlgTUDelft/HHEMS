import 'dart:convert';

import 'package:hems_app/model/api/device_status.dart';
import 'package:hems_app/model/api/schedule_job.dart';
import 'package:hems_app/service/timeshifter_service.dart';
import 'package:complex/complex.dart';
import 'package:test/test.dart';
import 'package:hems_app/model/api/measurement.dart';

void main() {
  final timeshifterService = TimeshifterService();

  final validJson = jsonDecode('''
  {
    "house_id": 1,
    "entity_name": "WashingMachine",
    "is_active": true,
    "progress": 0.75,
    "active_job_idx": 1,
    "scheduled_jobs": [],
    "consumption": {"value": 10.0, "unit": "kWh"},
    "profile": [{"re": 1.0, "im": 2.0}],
    "active_job": null
  }
  ''');

  final invalidJson = jsonDecode('{"invalid": "json"}');

  final deviceStatus = DeviceStatus(
    1,
    'WashingMachine',
    true,
    0.75,
    1,
    [],
    Measurement(10.0, 'kWh'),
    [Complex(1.0, 2.0)],
    null,
  );

  // Integration tests expect the basic configuration provided by the client in the backend.
  group('jsonToDeviceStatus Tests', () {
    test('Valid json successful', () {
      final result = timeshifterService.jsonToDeviceStatus(validJson);
      expect(result.isLeft, true);
      expect(result.left, deviceStatus);
    });

    test('Invalid json unsuccessful', () {
      final result = timeshifterService.jsonToDeviceStatus(invalidJson);
      expect(result.isRight, true);
    });
  });

  group(
    'Integration tests',
    () {
      final houseId = 0;
      final entityName = 'WashingMachine';

      test('getTimeshifterProperties works', () async {
        final result = await timeshifterService.getTimeshifterProperties(
          houseId,
          entityName,
        );
        expect(result.isLeft, true);
      });

      test('scheduleJob works + cancelJob works', () async {
        final job = ScheduleJob(0, 4321);

        final result = await timeshifterService.scheduleJob(
          houseId,
          entityName,
          job,
        );
        expect(result.isLeft, true);
        final result1 = await timeshifterService.cancelJob(
          houseId,
          entityName,
          0,
        );
        expect(result1.isLeft, true);
      });

      test('shutdownTimeshifter works', () async {
        final result = await timeshifterService.shutdownTimeshifter(
          houseId,
          entityName,
        );
        expect(result.isLeft, true);
      });

      test('getCurrentHouseTime works', () async {
        final result = await timeshifterService.getCurrentHouseTime(houseId);
        expect(result.isLeft, true);
        expect(int.tryParse(result.left), isNotNull);
      });
    },
    tags: ['integration'],
    skip:
        const bool.hasEnvironment('HEMS_URL')
            ? false
            : 'HEMS_URL not set, skipping integration test',
  );
}
