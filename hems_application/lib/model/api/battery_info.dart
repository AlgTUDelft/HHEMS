import 'battery_status.dart';

/// Data wrapper class for handling backend requests.
class BatteryInfo {
  double capacity = 0;
  double consumption = 0;
  double maxCharge = 0;
  double maxDischarge = 0;
  double stateOfCharge = 0;
  BatteryStatus status = BatteryStatus.idle;
  double? targetSoc;

  BatteryInfo(
    this.capacity,
    this.consumption,
    this.maxCharge,
    this.maxDischarge,
    this.stateOfCharge,
    this.status, [
    this.targetSoc,
  ]);

  BatteryInfo.fromJson(Map<String, dynamic> json) {
    capacity = (json['capacity'] as num).toDouble();
    consumption = (json['consumption'] as num).toDouble();
    maxCharge = (json['max_charge'] as num).toDouble();
    maxDischarge = (json['max_discharge'] as num).toDouble();
    stateOfCharge = (json['state_of_charge'] as num).toDouble();

    status = switch (json['status']) {
      'Charging' => BatteryStatus.charging,
      'Discharging' => BatteryStatus.discharging,
      'Idle' => BatteryStatus.idle,
      _ => throw FormatException('Invalid battery status'),
    };

    targetSoc = (json['target_soc'] as num?)?.toDouble();
  }

  @override
  int get hashCode => Object.hash(
    capacity,
    consumption,
    maxCharge,
    maxDischarge,
    stateOfCharge,
    status,
    targetSoc,
  );

  @override
  bool operator ==(Object other) {
    return other is BatteryInfo &&
        other.capacity == capacity &&
        other.consumption == consumption &&
        other.maxCharge == maxCharge &&
        other.maxDischarge == maxDischarge &&
        other.stateOfCharge == stateOfCharge &&
        other.status == status &&
        other.targetSoc == targetSoc;
  }
}
