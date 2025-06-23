import 'package:hems_app/util/hems_backend_util.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  final hemsBackendUtil = HemsBackendUtil();

  final response1 = http.Response('body', 200);
  final response2 = http.Response('body', 500);
  final response3 = http.Response('{"key": "value"}', 200);
  final response4 = http.Response('{"key": "value"}', 500);

  group('responseToString tests', () {
    test('Status 200 successful', () {
      final result = hemsBackendUtil.responseToString(response1);

      expect(result.isLeft, true);
      expect(result.left, 'body');
    });
    test('Status 500 unsuccessful', () {
      final result = hemsBackendUtil.responseToString(response2);

      expect(result.isRight, true);
    });
  });

  group('responseToJson tests', () {
    test('Status 200 successful', () {
      final result = hemsBackendUtil.responseToJson(response3);

      expect(result.isLeft, true);
      expect(result.left, {'key': 'value'});
    });
    test('Status 500 unsuccessful', () {
      final result = hemsBackendUtil.responseToJson(response4);

      expect(result.isRight, true);
    });
    test('Invalid json unsuccessful', () {
      final result = hemsBackendUtil.responseToJson(response1);

      expect(result.isRight, true);
    });
  });

  group('no url error tests', () {
    final hemsBackendUtilNoUrl = HemsBackendUtil();
    hemsBackendUtilNoUrl.baseUrl = null;

    test('get plain no url error', () async {
      final result = await hemsBackendUtilNoUrl.getPlain('');
      expect(result.isRight, true);
    });
    test('get json no url error', () async {
      final result = await hemsBackendUtilNoUrl.getJson('');
      expect(result.isRight, true);
    });
    test('delete plain no url error', () async {
      final result = await hemsBackendUtilNoUrl.deletePlain('');
      expect(result.isRight, true);
    });
    test('post json no url error', () async {
      final result = await hemsBackendUtilNoUrl.postJSON('', {});
      expect(result.isRight, true);
    });
  });
}
