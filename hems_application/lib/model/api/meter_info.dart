/// Data wrapper class for handling backend requests.
class MeterInfo {
  double? currentExport;
  double? currentImport;
  int houseId = 0;
  int meterId = 0;
  double totalExport = 0;
  double totalImport = 0;

  MeterInfo(
    this.currentExport,
    this.currentImport,
    this.houseId,
    this.meterId,
    this.totalExport,
    this.totalImport,
  );

  MeterInfo.fromJson(Map<String, dynamic> json) {
    currentExport = (json['current_export'] as num?)?.toDouble();
    currentImport = (json['current_import'] as num?)?.toDouble();
    houseId = json['house_id'] as int;
    meterId = json['meter_id'] as int;
    totalExport = (json['total_export'] as num).toDouble();
    totalImport = (json['total_import'] as num).toDouble();
  }

  @override
  int get hashCode => Object.hash(
    currentExport,
    currentImport,
    houseId,
    meterId,
    totalExport,
    totalImport,
  );

  @override
  bool operator ==(Object other) {
    return other is MeterInfo &&
        other.currentExport == currentExport &&
        other.currentImport == currentImport &&
        other.houseId == houseId &&
        other.meterId == meterId &&
        other.totalExport == totalExport &&
        other.totalImport == totalImport;
  }
}
