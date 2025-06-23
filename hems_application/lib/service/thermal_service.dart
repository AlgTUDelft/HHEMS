import 'package:either_dart/either.dart';
import 'package:hems_app/model/api/thermal_info.dart';
import 'package:hems_app/util/hems_backend_util.dart';

/// Service for handling thermal requests.
class ThermalService {
  static final ThermalService _instance = ThermalService._();
  final HemsBackendUtil _hemsBackendUtil = HemsBackendUtil();

  factory ThermalService() {
    return _instance;
  }

  ThermalService._();

  /// Returns the [ThermalInfo] for the thermal deivce with id [thermalId] in the house with id [houseId].
  ///
  /// If successful returns a Left containing the revalant [ThermalInfo].
  /// Otherwise returns a Right containing an error message.
  /// [houseId] is currently ignored by the backend so its actual value does not matter. Instead [thermalId]
  /// is used as the house id by the backend.
  Future<Either<ThermalInfo, String>> getThermalInfo(
    int houseId,
    int thermalId,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/thermal/$thermalId',
    );
    return response.thenLeft((v) => jsonToThermalInfo(v));
  }

  /// Converts the [json] to a [ThermalInfo] object.
  ///
  /// Returns a Left containing the result if [json] is a valid [ThermalInfo] json.
  /// Otherwise returns a Right containing an error message.
  Either<ThermalInfo, String> jsonToThermalInfo(Map<String, dynamic> json) {
    try {
      return Left(ThermalInfo.fromJson(json));
    } catch (_) {
      return Right('Not a valid thermal info JSON');
    }
  }

  /// Sets the target temperature for the thermal device with id [thermalId] in the house with id [houseId] to [temp].
  ///
  /// If successful returns a Left containing the updated target temperature.
  /// Otherwise returns a Right containing an error message.
  /// [thermalId] is currently ignored by the backend so its actual value does not matter.
  Future<Either<double, String>> setTargetTemperature(
    int houseId,
    int thermalId,
    double temp,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/thermal/$thermalId/target/$temp',
    );
    return response.thenLeft((v) => jsonToTemperature(v));
  }

  /// Converts the [json] to a double.
  ///
  /// Returns a Left containing the result if [json] is a valid json containing the target temperature.
  /// Otherwise returns a Right containing an error message.
  Either<double, String> jsonToTemperature(Map<String, dynamic> json) {
    try {
      return Left((json['target_temperature'] as num).toDouble());
    } catch (_) {
      return Right('Not a valid JSON with a target temperature');
    }
  }
}
