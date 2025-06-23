import 'package:either_dart/either.dart';
import 'package:hems_app/model/api/solar_info.dart';
import 'package:hems_app/util/hems_backend_util.dart';

/// Service for handling solar devices requests.
class SolarService {
  static final SolarService _instance = SolarService._();
  final HemsBackendUtil _hemsBackendUtil = HemsBackendUtil();

  factory SolarService() {
    return _instance;
  }

  SolarService._();

  /// Returns the [SolarInfo] for the solar panel with id [solarId] in the house with id [houseId].
  ///
  /// If successful returns a Left containing the [SolarInfo] object.
  /// Otherwise returns a Right containing an error message.
  /// [houseId] is currently ignored by the backend so its actual value does not matter. Instead [solarId]
  /// is used as the house id by the backend.
  Future<Either<SolarInfo, String>> getSolarInfo(
    int houseId,
    int solarId,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/solar/$solarId',
    );
    return response.thenLeft((v) => jsonToSolarInfo(v));
  }

  /// Converts the [json] to a [SolarInfo] object.
  ///
  /// Returns a Left containing the result if [json] is a valid [SolarInfo] json.
  /// Otherwise returns a Right containing an error message.
  Either<SolarInfo, String> jsonToSolarInfo(Map<String, dynamic> json) {
    try {
      return Left(SolarInfo.fromJson(json));
    } catch (_) {
      return Right('Not a valid solar info JSON');
    }
  }

  /// Sets the state of the solar panel with id [solarId] in the house with id [houseId] to [state].
  ///
  /// If successful returns a Left containing the result sent by the server.
  /// Otherwise returns a Right containing an error message.
  /// [solarId] is currently ignored by the backend so its actual value does not matter.
  Future<Either<String, String>> setState(
    int houseId,
    int solarId,
    bool state,
  ) {
    return _hemsBackendUtil.getPlain(
      'houses/$houseId/solar/$solarId/toggle/$state',
    );
  }
}
