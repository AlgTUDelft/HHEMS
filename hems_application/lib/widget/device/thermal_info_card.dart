import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/api/thermal_info.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/service/thermal_service.dart';

import 'thermometer_painter.dart';

class ThermalInfoCard extends StatefulWidget {
  final Device thermostat;
  const ThermalInfoCard({required this.thermostat, super.key});

  @override
  State<ThermalInfoCard> createState() => ThermalInfoState();
}

class ThermalInfoState extends State<ThermalInfoCard> {
  Either<ThermalInfo, String>? thermalInfo;
  Timer? timer;
  final _thermalService = ThermalService();

  /// Initializes the thermal info card widget.
  ///
  /// In addition, starts a timer to refresh the widget every second.
  @override
  void initState() {
    super.initState();
    loadThermal();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => loadThermal());
  }

  /// Updates the widget with new thermal information.
  Future<void> loadThermal() async {
    final info = await _thermalService.getThermalInfo(
      widget.thermostat.houseId,
      int.parse(widget.thermostat.deviceId),
    );
    if (!mounted) return;
    setState(() {
      thermalInfo = info;
    });
  }

  /// Disposes the widget.
  ///
  /// In addition cancels the refresh timer.
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// Builds the widget.
  ///
  /// If [thermalInfo] is not loaded yet it shows a progress indicator.
  /// If there was an error during loading [thermalInfo] it shows the relevant error message.
  /// Otherwise displays a thermometer showing temperature and target temperature.
  /// Also sets target temperature when clicked.
  @override
  Widget build(BuildContext context) {
    if (thermalInfo == null) return Center(child: CircularProgressIndicator());
    if (thermalInfo!.isRight) return Center(child: Text(thermalInfo!.right));

    double width = 50;
    double height = 200;

    ThermalInfo ti = thermalInfo!.left;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.temperature,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragStart: (details) {
                  _updateTemperature(details.localPosition);
                },
                onVerticalDragUpdate: (details) {
                  _updateTemperature(details.localPosition);
                },
                onVerticalDragEnd: (details) {
                  _commitTemperature();
                },
                onTapUp: (details) {
                  _updateTemperature(details.localPosition);
                  _commitTemperature();
                },
                child: CustomPaint(
                  size: Size(width, height),
                  painter: ThermometerPainter(
                    context,
                    ti.currentTemperature,
                    ti.targetTemperature,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculates where the temperature should be based on [localPos].
  /// 
  /// The range is between 1 and 34 degrees.
  void _updateTemperature(Offset localPos) {
    final columnTop = 50 / 4;
    final columnHeight = 200 - 50 / 4 - 50;

    double ratio = (localPos.dy - columnTop) / columnHeight;
    double temp = 35 * (1 - ratio);
    temp = temp.clamp(1, 34);

    if (thermalInfo != null && thermalInfo!.isLeft) {
      setState(() {
        thermalInfo!.left.targetTemperature = temp;
      });
    }
  }

  /// Async method for setting target temperature for a [thermalInfo] device using [ThermalService] service class.
  Future<void> _commitTemperature() async {
    if (thermalInfo == null || !thermalInfo!.isLeft) return;
    final temp = thermalInfo!.left.targetTemperature;

    final newTarget = await _thermalService.setTargetTemperature(
      widget.thermostat.houseId,
      int.parse(widget.thermostat.deviceId),
      temp,
    );

    if (!mounted) return;
    setState(() {
      if (newTarget.isLeft) {
        thermalInfo!.left.targetTemperature = newTarget.left;
      }
    });
  }
}
