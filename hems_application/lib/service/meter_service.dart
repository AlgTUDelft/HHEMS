import 'package:either_dart/either.dart';
import 'package:hems_app/model/api/meter_info.dart';
import 'package:hems_app/util/hems_backend_util.dart';

/// Service for handling meter requests.
class MeterService {
  static final MeterService _instance = MeterService._();
  final HemsBackendUtil _hemsBackendUtil = HemsBackendUtil();

  factory MeterService() {
    return _instance;
  }

  MeterService._();

  /// Returns the [MeterInfo] for the meter with id [meterId] in the house with id [houseId].
  ///
  /// If successful returns a Left containing the revalant [MeterInfo].
  /// Otherwise returns a Right containing an error message.
  Future<Either<MeterInfo, String>> getMeterInfo(
    int houseId,
    int meterId,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/meters/$meterId',
    );
    return response.thenLeft((v) => jsonToMeterInfo(v));
  }

  /// Converts the [json] to a [MeterInfo] object.
  ///
  /// Returns a Left containing the result if [json] is a valid [MeterInfo] json.
  /// Otherwise returns a Right containing an error message.
  Either<MeterInfo, String> jsonToMeterInfo(Map<String, dynamic> json) {
    try {
      return Left(MeterInfo.fromJson(json));
    } catch (_) {
      return Right('Not a valid meter info JSON');
    }
  }
}
