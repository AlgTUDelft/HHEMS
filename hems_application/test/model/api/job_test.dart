import 'package:test/test.dart';
import 'package:hems_app/model/api/job.dart';

void main() {
  group('Job Equality and HashCode', () {
    final job1 = Job(1000, 2000);
    final job2 = Job(1000, 2000);
    final job3 = Job(3000, 4000);

    test('Jobs with same data are equal', () {
      expect(job1, equals(job2));
    });

    test('Jobs with different data are not equal', () {
      expect(job1, isNot(equals(job3)));
    });

    test('HashCodes are consistent with equality', () {
      expect(job1.hashCode, equals(job2.hashCode));
    });
  });

  group('Job fromJson', () {
    test('Correctly parses from JSON', () {
      final json = {'startTime': 5000, 'endTime': 6000};
      final job = Job.fromJson(json);

      expect(job.startTime, 5000);
      expect(job.endTime, 6000);
    });
  });
}
