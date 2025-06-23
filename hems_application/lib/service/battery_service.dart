import 'package:either_dart/either.dart';
import 'package:hems_app/model/api/battery_info.dart';
import 'package:hems_app/util/hems_backend_util.dart';

/// Service for handling battery requests.
class BatteryService {
  static final BatteryService _instance = BatteryService._();
  final HemsBackendUtil _hemsBackendUtil = HemsBackendUtil();

  factory BatteryService() {
    return _instance;
  }

  BatteryService._();

  /// Returns the [BatteryInfo] for the battery with id [batteryId] in the house with id [houseId].
  ///
  /// If successful returns a Left containing the revalant [BatteryInfo].
  /// Otherwise returns a Right containing an error message.
  /// [batteryId] is currently ignored by the backend so its actual value does not matter.
  Future<Either<BatteryInfo, String>> getBatteryInfo(
    int houseId,
    int batteryId,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/battery/$batteryId',
    );
    return response.thenLeft((v) => jsonToBatteryInfo(v));
  }

  /// Converts the [json] to an [BatteryInfo] object.
  ///
  /// Returns a Left containing the result if [json] is a valid [BatteryInfo] json.
  /// Otherwise returns a Right containing an error message.
  Either<BatteryInfo, String> jsonToBatteryInfo(Map<String, dynamic> json) {
    try {
      return Left(BatteryInfo.fromJson(json));
    } catch (_) {
      return Right('Not a valid battery info JSON');
    }
  }

  /// Sets the target state of charge for the battery with id [batteryId] in the house with id [houseId] to [soc].
  ///
  /// If successful returns a Left containing the updated [BatteryInfo].
  /// Otherwise returns a Right containing an error message.
  /// [batteryId] is currently ignored by the backend so its actual value does not matter.
  Future<Either<BatteryInfo, String>> setTargetSOC(
    int houseId,
    int batteryId,
    int soc,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/battery/$batteryId/target/$soc',
    );
    return response.thenLeft((v) => jsonToBatteryInfo(v));
  }

  /// Unsets the target state of charge for the battery with id [batteryId] in the house with id [houseId].
  ///
  /// If successful returns a Left containing the updated [BatteryInfo].
  /// Otherwise returns a Right containing an error message.
  /// [batteryId] is currently ignored by the backend so its actual value does not matter.
  Future<Either<BatteryInfo, String>> unsetTargetSOC(
    int houseId,
    int batteryId,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/battery/$batteryId/target',
    );
    return response.thenLeft((v) => jsonToBatteryInfo(v));
  }
}
