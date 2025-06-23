import 'dart:convert';
import 'package:test/test.dart';
import 'package:complex/complex.dart';
import 'package:hems_app/model/api/device_status.dart';
import 'package:hems_app/model/api/job.dart';
import 'package:hems_app/model/api/measurement.dart';

void main() {
  final job1 = Job(1000, 2000);
  final job2 = Job(3000, 4000);
  final consumption = Measurement(150.5, 'W');

  final profile = [Complex(1.0, -1.0), Complex(2.0, 3.0)];

  final devStatus1 = DeviceStatus(
    1,
    'EntityA',
    true,
    50.0,
    0,
    [job1],
    consumption,
    profile,
  );

  final devStatus2 = DeviceStatus(
    1,
    'EntityA',
    true,
    50.0,
    0,
    [job1],
    consumption,
    profile,
  );

  final devStatus3 = DeviceStatus(
    2,
    'EntityB',
    false,
    75.0,
    1,
    [job1, job2],
    consumption,
    profile,
    job2,
  );

  final json1 = jsonDecode('''{
    "house_id": 1,
    "entity_name": "EntityA",
    "is_active": true,
    "progress": 50.0,
    "active_job_idx": 0,
    "scheduled_jobs": [{"startTime": 1000, "endTime": 2000}],
    "consumption": {"value": 150.5, "unit": "W"},
    "profile": [{"re": 1.0, "im": -1.0}, {"re": 2.0, "im": 3.0}],
    "active_job": null
  }''');

  final json2 = jsonDecode('''{
    "house_id": 2,
    "entity_name": "EntityB",
    "is_active": false,
    "progress": 75.0,
    "active_job_idx": 1,
    "scheduled_jobs": [{"startTime": 1000, "endTime": 2000}, {"startTime": 3000, "endTime": 4000}],
    "consumption": {"value": 150.5, "unit": "W"},
    "profile": [{"re": 1.0, "im": -1.0}, {"re": 2.0, "im": 3.0}],
    "active_job": {"startTime": 3000, "endTime": 4000}
  }''');

  group('== operator tests', () {
    test('Equality true for identical objects', () {
      expect(devStatus1, equals(devStatus1));
      expect(devStatus1, equals(devStatus2));
    });

    test('Equality false when houseId changes', () {
      expect(devStatus1, isNot(equals(devStatus3)));
    });

    test('Equality false when activeJob differs', () {
      final devStatusWithJob = DeviceStatus(
        1,
        'EntityA',
        true,
        50.0,
        0,
        [job1],
        consumption,
        profile,
        job1,
      );
      expect(devStatus1, isNot(equals(devStatusWithJob)));
    });
  });

  group('Hashcode tests', () {
    test('Hashcode consistent with equality', () {
      expect(devStatus1.hashCode, equals(devStatus2.hashCode));
    });

  });

  group('fromJson tests', () {
    test('fromJson parses correctly without active job', () {
      final parsed = DeviceStatus.fromJson(json1);
      expect(parsed, equals(devStatus1));
    });

    test('fromJson parses correctly with active job', () {
      final parsed = DeviceStatus.fromJson(json2);
      expect(parsed, equals(devStatus3));
    });
  });
}
