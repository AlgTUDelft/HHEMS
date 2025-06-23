/// Data wrapper class for handling backend requests.
class SolarInfo {
  double consumption = 0;

  SolarInfo(this.consumption);

  SolarInfo.fromJson(Map<String, dynamic> json) {
    consumption = (json['consumption'] as num).toDouble();
  }

  @override
  int get hashCode => consumption.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SolarInfo && other.consumption == consumption;
  }
}
