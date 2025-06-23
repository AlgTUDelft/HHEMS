import 'package:flutter/material.dart';
import 'package:hems_app/l10n/app_localizations.dart';
import 'package:hems_app/widget/device/battery_info_card.dart';
import 'package:hems_app/widget/device/ha_entity_info_card.dart';
import 'package:hems_app/widget/device/meter_info_card.dart';
import 'package:hems_app/widget/device/solar_info_card.dart';
import 'package:hems_app/widget/device/thermal_info_card.dart';
import 'package:hems_app/widget/device/timeshifter_card.dart';

/// Types of devices currently available in the backend.
enum DeviceType { solar, thermal, timeshifter, meter, battery, haEntity }

extension DeviceTypeExtension on DeviceType {
  /// Returns the name [String] for this device type.
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      DeviceType.solar => l10n.solarPanel,
      DeviceType.thermal => l10n.thermalDevice,
      DeviceType.timeshifter => l10n.consumerDevice,
      DeviceType.meter => l10n.meterDevice,
      DeviceType.battery => l10n.battery,
      DeviceType.haEntity => l10n.onOffDevice,
    };
  }

  /// Returns the [IconData] for this device type.
  IconData get iconData {
    return switch (this) {
      DeviceType.solar => Icons.solar_power_outlined,
      DeviceType.thermal => Icons.thermostat_outlined,
      DeviceType.timeshifter => Icons.power,
      DeviceType.meter => Icons.speed,
      DeviceType.battery => Icons.battery_full_outlined,
      DeviceType.haEntity => Icons.toggle_on,
    };
  }
}

class Device {
  int houseId;
  String deviceId;
  DeviceType type;

  /// Creates a new [Device]
  ///
  /// The device is in a house with [houseId].
  /// The device's id in the house is [deviceId]
  /// [type] The type of the device
  Device({required this.houseId, required this.deviceId, required this.type});

  @override
  int get hashCode => Object.hash(houseId, deviceId, type);

  @override
  bool operator ==(Object other) {
    return other is Device &&
        other.houseId == houseId &&
        other.deviceId == deviceId &&
        other.type == type;
  }

  /// Returns the [StatefulWidget] for this device type.
  StatefulWidget get widget {
    return switch (type) {
      DeviceType.solar => SolarInfoCard(solarPanel: this),
      DeviceType.thermal => ThermalInfoCard(thermostat: this),
      DeviceType.meter => MeterInfoCard(meter: this),
      DeviceType.battery => BatteryInfoCard(battery: this),
      DeviceType.timeshifter => TimeshifterCard(deviceId),
      DeviceType.haEntity => HaEntityInfoCard(entity: this),
    };
  }

  Device.fromJson(Map<String, dynamic> json) :
    houseId = json['house_id'] as int,
    deviceId = json['device_id'] as String,
    type = switch(json['type']) {
      'solar' => DeviceType.solar,
      'thermal' => DeviceType.thermal,
      'timeshifter' => DeviceType.timeshifter,
      'meter' => DeviceType.meter,
      'battery' => DeviceType.battery,
      'haEntity' => DeviceType.haEntity,
      _ => throw FormatException('Invalid device type'),
    };

  Map<String, dynamic> toJson() => {
    'house_id': houseId,
    'device_id': deviceId,
    'type': switch(type) {
      DeviceType.solar => 'solar',
      DeviceType.thermal => 'thermal',
      DeviceType.timeshifter=> 'timeshifter',
      DeviceType.meter => 'meter',
      DeviceType.battery => 'battery',
      DeviceType.haEntity => 'haEntity',
    }
  };
}
