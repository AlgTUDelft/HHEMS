import 'dart:convert';

import 'package:hems_app/model/api/entity_request.dart';
import 'package:test/test.dart';

void main() {
  final entityReq1 = EntityRequest('1', "1000");
  final entityReq2 = EntityRequest('1', "1000");
  final entityReq3 = EntityRequest('2', "1000");
  final entityReq4 = EntityRequest('1', "1200.25");

  final json = jsonDecode('''{
  "entity_id": "1",
  "consumption": "1000"
}''');

  group('== operator tests', () {
    test('Equality true', () {
      expect(entityReq1, equals(entityReq1));
      expect(entityReq1, equals(entityReq2));
      expect(entityReq2, equals(entityReq2));
    });
    test('Equality considers entityId', () {
      expect(entityReq1, isNot(equals(entityReq3)));
    });
    test('Equality considers consumption', () {
      expect(entityReq1, isNot(equals(entityReq4)));
    });
  });

  group('Hashcode tests', () {
    test('Hashcode consistent with equality', () {
      expect(entityReq1.hashCode, equals(entityReq1.hashCode));
      expect(entityReq1.hashCode, equals(entityReq2.hashCode));
      expect(entityReq2.hashCode, equals(entityReq2.hashCode));
    });
  });

  group('fromJson tests', () {
    test('fromJson works', () {
      expect(EntityRequest.fromJson(json), entityReq1);
    });
  });
}
