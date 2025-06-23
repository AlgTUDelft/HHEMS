import 'dart:convert';

import 'package:hems_app/model/api/entity_request.dart';
import 'package:hems_app/service/entity_service.dart';
import 'package:test/test.dart';

void main() {
  final entityService = EntityService();

  group('jsonToEntityRequest Tests', () {
    final entityRequest = EntityRequest("1", "1000.0");
    final json1 = jsonDecode('''{
      "entity_id": "1",
      "consumption": "1000.0"
    }''');
    final json2 = jsonDecode('''{
      "consumption": "350.0"
    }''');

    test('Valid json successful', () {
      final result = entityService.jsonToEntityRequest(json1);

      expect(result.isLeft, true);
      expect(result.left, entityRequest);
    });
    test('Invalid json unsuccessful', () {
      final result = entityService.jsonToEntityRequest(json2);

      expect(result.isRight, true);
    });
  });

  // Integration tests expect the basic configuration provided by the client in the backend.
  // In addition it expects home assistant to be configured with the demo configuration.
  group(
    'Integration tests',
    () {
      test('getEntityState works', () async {
        final result = await entityService.getEntityState(0, "light.bed_light");
        expect(result.isLeft, true);
      });
      test('setEntityState works', () async {
        final result1 = await entityService.setEntityState(
          0,
          "light.bed_light",
          false,
        );
        expect(result1.isLeft, true);

        final result2 = await entityService.getEntityState(
          0,
          "light.bed_light",
        );
        expect(result2.isLeft, true);
        expect(result2.left['state'], 'off');

        final result3 = await entityService.setEntityState(
          0,
          "light.bed_light",
          true,
        );
        expect(result3.isLeft, true);

        final result4 = await entityService.getEntityState(
          0,
          "light.bed_light",
        );
        expect(result4.isLeft, true);
        expect(result4.left['state'], 'on');
      });
      test('getEntityConsumption works', () async {
        final result = await entityService.getEntityConsumption(0, "sensor.power_consumption");
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
