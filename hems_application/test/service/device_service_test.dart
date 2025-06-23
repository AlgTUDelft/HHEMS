import 'package:hems_app/service/device_service.dart';
import 'package:test/test.dart';

void main() {
  final deviceService = DeviceService();

  // Integration tests expect the basic configuration provided by the client in the backend.
  test('Valid json successful', () async {
    final result = await deviceService.getDevices();
    expect(result.isLeft, true);
  });
}
