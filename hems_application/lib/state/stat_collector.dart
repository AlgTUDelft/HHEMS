import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hems_app/model/api/battery_info.dart';
import 'package:hems_app/model/api/battery_status.dart';
import 'package:hems_app/model/api/measurement.dart';
import 'package:hems_app/model/api/meter_info.dart';
import 'package:hems_app/model/api/solar_info.dart';
import 'package:hems_app/service/battery_service.dart';
import 'package:hems_app/service/meter_service.dart';
import 'package:hems_app/service/solar_service.dart';
import 'package:hems_app/widget/analytics/power_flow_painter.dart';

/// A singleton class that collects and manages statistics.
///
/// It extends [ChangeNotifier] to allow widgets to listen for changes in the state and update
/// accordingly.
class StatCollector extends ChangeNotifier {
  static final StatCollector _instance = StatCollector._internal();

  List<MapEntry<Measurement, DateTime>> consumptionData = [];
  List<PowerSink> consumers = [];
  List<PowerSink> producers = [];

  final MeterService _meterService = MeterService();
  final BatteryService _batteryService = BatteryService();
  final SolarService _solarService = SolarService();

  StatCollector._internal();

  /// Starts a timer to poll consumption every 5 seconds
  /// 
  /// Should be called in main before the application starts
  void startPolling() {
    Timer.periodic(
      const Duration(seconds: 5),
      (Timer t) => pollConsumption(),
    );
  }

  /// A singleton class that collects and manages statistics.
  ///
  /// It extends [ChangeNotifier] to allow widgets to listen for changes in the state and update
  /// accordingly.
  factory StatCollector() {
    return _instance;
  }

  /// Gets the power consumption in Watts of all of the devices in the configuration every 5 seconds.
  ///
  /// The list consumptionData holds the last 12 power consumption values, i.e. the values
  /// from the past minute.
  void pollConsumption() async {
    final meterInfo = await _meterService.getMeterInfo(0, 0);
    final solarInfo = await _solarService.getSolarInfo(0, 0);
    final batteryInfo = await _batteryService.getBatteryInfo(0, 0);
    if (meterInfo.isRight || solarInfo.isRight || batteryInfo.isRight) return;

    MeterInfo mi = meterInfo.left;
    SolarInfo si = solarInfo.left;
    BatteryInfo bi = batteryInfo.left;

    consumers = [];
    producers = [];

    double batteryConsumption = 0;
    if (bi.status == BatteryStatus.charging) {
      batteryConsumption = -bi.consumption;
      consumers.add(PowerSink.battery);
    } else if (bi.status == BatteryStatus.discharging) {
      batteryConsumption = bi.consumption;
      producers.add(PowerSink.battery);
    }

    if (si.consumption > 0) {
      producers.add(PowerSink.solar);
    }

    if ((mi.currentExport ?? 0) > 0) {
      consumers.add(PowerSink.net);
    } else if ((mi.currentImport ?? 0) > 0) {
      producers.add(PowerSink.net);
    }

    double deviceConsumption =
        (mi.currentImport ?? 0) -
        (mi.currentExport ?? 0) +
        si.consumption +
        batteryConsumption;

    if (deviceConsumption > 0) {
      consumers.add(PowerSink.devices);
    }

    DateTime now = DateTime.now();
    if (consumptionData.length == 12) {
      consumptionData.remove(consumptionData.first);
    }

    consumptionData.add(MapEntry(Measurement(deviceConsumption, "W"), now));
    notifyListeners();
  }
}
