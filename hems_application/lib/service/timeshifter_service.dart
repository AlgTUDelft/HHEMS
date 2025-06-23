import 'package:either_dart/either.dart';
import 'package:hems_app/model/api/device_status.dart';
import 'package:hems_app/model/api/job.dart';
import 'package:hems_app/model/api/schedule_job.dart';
import 'package:hems_app/util/hems_backend_util.dart';

/// Service for handling timeshifter devices requests.
class TimeshifterService {
  static final TimeshifterService _instance = TimeshifterService._();
  final HemsBackendUtil _hemsBackendUtil = HemsBackendUtil();

  factory TimeshifterService() {
    return _instance;
  }

  TimeshifterService._();

  /// Returns the [DeviceStatus] for the timeshifter with name [entityName] in the house with id [houseId].
  ///
  /// If successful returns a Left containing the revalant [DeviceStatus].
  /// Otherwise returns a Right containing an error message.
  Future<Either<DeviceStatus, String>> getTimeshifterProperties(
    int houseId,
    String entityName,
  ) async {
    final response = await _hemsBackendUtil.getJson(
      'houses/$houseId/timeshifters/$entityName',
    );
    return response.thenLeft((v) => jsonToDeviceStatus(v));
  }

  /// Converts the [json] to a [DeviceStatus] object.
  ///
  /// Returns a Left containing the result if [json] is a valid [DeviceStatus] json.
  /// Otherwise returns a Right containing an error message.
  /// [DeviceStatus] is analogous with Timeshifter.
  Either<DeviceStatus, String> jsonToDeviceStatus(Map<String, dynamic> json) {
    try {
      return Left(DeviceStatus.fromJson(json));
    } catch (_) {
      return Right('Not a valid device status JSON');
    }
  }

  /// Posts a job [ScheduleJob] for an entity [entityName] in house with id [houseId]
  ///
  /// If successful returns a Left containing the revalant [Job].
  /// Otherwise returns a Right containing an error message.
  Future<Either<Job, String>> scheduleJob(
    int houseId,
    String entityName,
    ScheduleJob job,
  ) async {
    final response = await _hemsBackendUtil.postJSON(
      'houses/$houseId/timeshifters/$entityName/job',
      job.toJson(),
    );
    return response.thenLeft((v) => jsonToJobMap(v));
  }

  /// Converts the [json] to a [Job] object.
  ///
  /// Returns a Left containing the result if [json] is a valid [Job] json.
  /// Otherwise returns a Right containing an error message.
  Either<Job, String> jsonToJobMap(Map<String, dynamic> json) {
    try {
      return Left(Job.fromJson(json));
    } catch (_) {
      return Right('Not a valid job JSON');
    }
  }

  /// Attempts to shutdown entity with name [entityName] from house with id [houseId]
  ///
  /// If successful returns a String confirming the shutdown
  /// Otherwise returns a Right containing an error message.
  Future<Either<String, String>> shutdownTimeshifter(
    int houseId,
    String entityName,
  ) async {
    final response = await _hemsBackendUtil.getPlain(
      'houses/$houseId/timeshifters/$entityName/shutdown',
    );
    return response;
  }

  /// Attempts to cancel job with id [jobId] entity with name [entityName] from house with id [houseId]
  ///
  /// If successful returns a String confirming the shutdown
  /// Otherwise returns a Right containing an error message.
  Future<Either<String, String>> cancelJob(
    int houseId,
    String entityName,
    int jobId,
  ) async {
    final response = await _hemsBackendUtil.deletePlain(
      'houses/$houseId/timeshifters/$entityName/job/$jobId',
    );
    return response;
  }

  /// Attempts to get the current time of house with id [houseId].
  ///
  /// That time might be different from the current time of the device if there's a desync or the house is a simulation.
  ///
  /// If successful returns a String of the current time in seconds since epoch. (You'll probably want to parse it as an int first)
  /// Otherwise returns a Right containing an error message.
  Future<Either<String, String>> getCurrentHouseTime(int houseId) {
    final response = _hemsBackendUtil.getPlain('houses/$houseId/time');
    return response;
  }
}
