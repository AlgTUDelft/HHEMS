import 'package:test/test.dart';
import 'package:hems_app/model/api/measurement.dart';

void main() {
  group('Measurement Equality and HashCode', () {
    final m1 = Measurement(150.0, 'W');
    final m2 = Measurement(150.0, 'W');
    final m3 = Measurement(200.0, 'kW');

    test('Measurements with same data are equal', () {
      expect(m1, equals(m2));
    });

    test('Measurements with different data are not equal', () {
      expect(m1, isNot(equals(m3)));
    });

    test('HashCodes are consistent with equality', () {
      expect(m1.hashCode, equals(m2.hashCode));
    });
  });

  group('Measurement fromJson', () {
    test('Correctly parses from JSON', () {
      final json = {'value': 99.5, 'unit': 'kWh'};
      final measurement = Measurement.fromJson(json);

      expect(measurement.value, 99.5);
      expect(measurement.unit, 'kWh');
    });
  });
}
