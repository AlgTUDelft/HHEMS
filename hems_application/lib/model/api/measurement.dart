/// Data wrapper class for handling backend requests.
class Measurement {
  double value;
  String unit;

  Measurement(this.value, this.unit);

  Measurement.fromJson(Map<String, dynamic> json)
    : value = (json['value'] as num).toDouble(),
      unit = json['unit'] as String;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement && other.value == value && other.unit == unit);

  @override
  int get hashCode => Object.hash(value, unit);
}
