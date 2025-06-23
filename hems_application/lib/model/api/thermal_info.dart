/// Data wrapper class for handling backend requests.
class ThermalInfo {
  double consumption = 0;
  double currentTemperature = 0;
  double heatingPower = 0;
  double targetTemperature = 0;

  ThermalInfo(
    this.consumption,
    this.currentTemperature,
    this.heatingPower,
    this.targetTemperature,
  );

  ThermalInfo.fromJson(Map<String, dynamic> json) {
    consumption = (json['consumption'] as num).toDouble();
    currentTemperature = (json['current_temperature'] as num).toDouble();
    heatingPower = (json['heating_power'] as num).toDouble();
    targetTemperature = (json['target_temperature'] as num).toDouble();
  }

  @override
  int get hashCode => Object.hash(
    consumption,
    currentTemperature,
    heatingPower,
    targetTemperature,
  );

  @override
  bool operator ==(Object other) {
    return other is ThermalInfo &&
        other.consumption == consumption &&
        other.currentTemperature == currentTemperature &&
        other.heatingPower == heatingPower &&
        other.targetTemperature == targetTemperature;
  }
}
