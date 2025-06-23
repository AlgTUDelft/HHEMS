import 'package:complex/complex.dart';
import 'package:flutter/foundation.dart';

import 'job.dart';
import 'measurement.dart';

/// Data wrapper class for handling backend requests.
class DeviceStatus {
  int houseId = 0;
  String entityName = '';
  bool isActive = false;
  double progress = 0.0;
  int activeJobIdx = -1;
  List<Job> scheduledJobs = [];
  Measurement consumption = Measurement(0.0, '');
  List<Complex> profile = [];
  Job? activeJob;

  DeviceStatus(
    this.houseId,
    this.entityName,
    this.isActive,
    this.progress,
    this.activeJobIdx,
    this.scheduledJobs,
    this.consumption,
    this.profile, [
    this.activeJob,
  ]);

  DeviceStatus.fromJson(Map<String, dynamic> json) {
    houseId = json['house_id'] as int;
    entityName = json['entity_name'] as String;
    isActive = json['is_active'] as bool;
    progress = (json['progress'] as num).toDouble();
    activeJobIdx = json['active_job_idx'] as int;

    scheduledJobs =
        (json['scheduled_jobs'] as List<dynamic>)
            .map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList();

    consumption = Measurement.fromJson(
      json['consumption'] as Map<String, dynamic>,
    );

    profile =
        (json['profile'] as List<dynamic>).map((e) {
          final map = e as Map<String, dynamic>;
          return Complex(
            (map['re'] as num).toDouble(),
            (map['im'] as num).toDouble(),
          );
        }).toList();

    activeJob =
        json['active_job'] != null
            ? Job.fromJson(json['active_job'] as Map<String, dynamic>)
            : null;
  }

  /// The minimum duration for a job that the backend will currently accept.
  Duration get minimumJobDuration {
    return Duration(
      seconds: profile.length,
    );
  }

  @override
  int get hashCode => Object.hash(
    houseId,
    entityName,
    isActive,
    progress,
    activeJobIdx,
    Object.hashAll(scheduledJobs),
    consumption,
    Object.hashAll(profile),
    activeJob,
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DeviceStatus &&
            other.houseId == houseId &&
            other.entityName == entityName &&
            other.isActive == isActive &&
            other.progress == progress &&
            other.activeJobIdx == activeJobIdx &&
            listEquals(other.scheduledJobs, scheduledJobs) &&
            other.consumption == consumption &&
            listEquals(other.profile, profile) &&
            other.activeJob == activeJob);
  }
}
