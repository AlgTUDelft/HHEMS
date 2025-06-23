import 'package:either_dart/either.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/util/hems_backend_util.dart';

/// Service for handling devices available in the house (backend), currently mocked.
class DeviceService {
  static final DeviceService _instance = DeviceService._();
  // ignore: unused_field
  final HemsBackendUtil _hemsBackendUtil = HemsBackendUtil();

  factory DeviceService() {
    return _instance;
  }

  DeviceService._();

  /// MOCK VERSION, Returns all the devices in the backend.
  ///
  /// When this functionality becomes available this will be replaced with a real network request.
  Future<Either<List<Device>, String>> getDevices() async {
    return Left([
      Device(deviceId: "0", houseId: 0, type: DeviceType.battery),
      Device(deviceId: "0", houseId: 0, type: DeviceType.meter),
      Device(deviceId: "0", houseId: 0, type: DeviceType.solar),
      Device(deviceId: "0", houseId: 0, type: DeviceType.thermal),
      Device(deviceId: "DishWasher", houseId: 0, type: DeviceType.timeshifter),
      Device(
        deviceId: "WashingMachine",
        houseId: 0,
        type: DeviceType.timeshifter,
      ),
      Device(
        deviceId: "light.bed_light",
        houseId: 0,
        type: DeviceType.haEntity,
      ),
    ]);
  }
}
