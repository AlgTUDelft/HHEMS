import 'package:either_dart/either.dart';
import 'package:hems_app/model/api/entity_request.dart';
import 'package:hems_app/util/hems_backend_util.dart';

/// Service for handling consumption of devices.
class EntityService {
  static final EntityService _instance = EntityService._();
  final HemsBackendUtil _hemsBackendUtil = HemsBackendUtil();

  factory EntityService() {
    return _instance;
  }

  EntityService._();

  /// Returns the [EntityRequest] for the entity with id [entityId] in the house with id [houseId].
  ///
  /// If successful returns a Left containing the relevant [EntityRequest].
  /// Otherwise returns a Right containing an error message.
  Future<Either<EntityRequest, String>> getEntityConsumption(
    int houseId,
    String entityId,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/entity/$entityId/consumption',
    );
    return response.thenLeft((v) => jsonToEntityRequest(v));
  }

  /// Returns the state for the entity with id [entityId] in the house with id [houseId].
  ///
  /// If successful returns a Left containing the revalant json.
  /// Otherwise returns a Right containing an error message.
  Future<Either<Map<String, dynamic>, String>> getEntityState(
    int houseId,
    String entityId,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/entity/$entityId/state',
    );
    return response.mapLeft((v) => v);
  }

  /// Sets the state for the entity with id [entityId] in the house with id [houseId] to [newState].
  ///
  /// If successful returns a Left containing the response of the server.
  /// Otherwise returns a Right containing an error message.
  Future<Either<dynamic, String>> setEntityState(
    int houseId,
    String entityId,
    bool newState,
  ) async {

    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/entity/$entityId/toggle/$newState',
    );
    return response.mapLeft((v) => v);
  }

  /// Converts the [json] to an [EntityRequest] object.
  ///
  /// Returns a Left containing the result if [json] is a valid [EntityRequest] json.
  /// Otherwise returns a Right containing an error message.
  Either<EntityRequest, String> jsonToEntityRequest(Map<String, dynamic> json) {
    try {
      return Left(EntityRequest.fromJson(json));
    } catch (_) {
      return Right('Not a valid entity request JSON');
    }
  }
}
