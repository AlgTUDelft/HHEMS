import 'package:test/test.dart';
import 'package:hems_app/model/api/schedule_job.dart';

void main() {
  group('Job Equality and HashCode', () {
    final job1 = ScheduleJob(1000, 2000);
    final job2 = ScheduleJob(1000, 2000);
    final job3 = ScheduleJob(3000, 4000);

    test('Scheduled Jobs with same data are equal', () {
      expect(job1, equals(job2));
    });

    test('Scheduled Jobs with different data are not equal', () {
      expect(job1, isNot(equals(job3)));
    });

    test('HashCodes are consistent with equality', () {
      expect(job1.hashCode, equals(job2.hashCode));
    });
  });

  group('Scheduled Job toJson', () {
    final job1 = ScheduleJob(1000, 2000);
    test('Correctly parses to Json', () {
      expect({'delay': 1000, 'duration': 2000}, job1.toJson());
    });
  });
}
