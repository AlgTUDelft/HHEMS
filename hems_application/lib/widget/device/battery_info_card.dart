import 'dart:async';
import 'dart:math' as math;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/api/battery_info.dart';
import 'package:hems_app/model/api/battery_status.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/service/battery_service.dart';

import 'battery_ring_painter.dart';

class BatteryInfoCard extends StatefulWidget {
  final Device battery;
  const BatteryInfoCard({required this.battery, super.key});

  @override
  State<BatteryInfoCard> createState() => BatteryState();
}

class BatteryState extends State<BatteryInfoCard> {
  Either<BatteryInfo, String>? batInfo;
  Timer? timer;
  final _batteryService = BatteryService();
  double? _dragTargetRatio;
  bool _isDragging = false;

  /// Initializes the battery info card widget.
  ///
  /// In addition, starts a timer to refresh the widget every second.
  @override
  void initState() {
    super.initState();
    loadBattery();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => loadBattery());
  }

  /// Updates the widget with new battery information.
  Future<void> loadBattery() async {
    final info = await _batteryService.getBatteryInfo(
      widget.battery.houseId,
      int.parse(widget.battery.deviceId),
    );
    if (!mounted) return;
    setState(() {
      batInfo = info;
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
  /// If [batInfo] is not loaded yet it shows a progress indicator.
  /// If there was an error during loading [batInfo] it shows the relevant error message.
  /// Otherwise displays a circular indicator showing battery charge state and target state of charge.
  /// The indicator sets or clears the target state of charge when clicked at the relevant places.
  /// Also displays the status of the battery with time estimates as required.
  /// The widget is both draggable and clickable.
  @override
  Widget build(BuildContext context) {
    if (batInfo == null) return Center(child: CircularProgressIndicator());
    if (batInfo!.isRight) return Center(child: Text(batInfo!.right));
    BatteryInfo bi = batInfo!.left;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.battery,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTapUp: (details) async {
                  final localPos = details.localPosition;
                  final center = Offset(100, 100);
                  final dx = localPos.dx - center.dx;
                  final dy = localPos.dy - center.dy;

                  final distanceFromCenter = math.sqrt(dx * dx + dy * dy);
                  const deadZoneRadius = 40.0;
                  if (distanceFromCenter < deadZoneRadius) return;

                  const startAngle = 0.75 * math.pi;
                  const sweep = 1.5 * math.pi;

                  double angle = math.atan2(dy, dx);
                  if (angle < 0) angle += 2 * math.pi;

                  double normalizedAngle = angle - startAngle;
                  if (normalizedAngle < 0) normalizedAngle += 2 * math.pi;

                  if (normalizedAngle > sweep) return;

                  double ratio = normalizedAngle / sweep;

                  // If close to 100%, round it to avoid float inaccuracies
                  if (ratio > 0.995) ratio = 1.0;
                  ratio = ratio.clamp(0.0, 1.0);

                  final target = (ratio * bi.capacity).toInt();

                  final info = await _batteryService.setTargetSOC(
                    widget.battery.houseId,
                    int.parse(widget.battery.deviceId),
                    target,
                  );

                  if (!mounted) return;
                  setState(() {
                    batInfo = info;
                    _dragTargetRatio = null;
                    _isDragging = false;
                  });
                },
                onPanStart: (_) {
                  if (bi.targetSoc != null) {
                    _dragTargetRatio = bi.targetSoc! / bi.capacity;
                  } else {
                    _dragTargetRatio = bi.stateOfCharge / bi.capacity;
                  }
                  _isDragging = true;
                },
                onPanUpdate: (details) {
                  final localPos = details.localPosition;
                  final center = Offset(100, 100);
                  final dx = localPos.dx - center.dx;
                  final dy = localPos.dy - center.dy;

                  final distanceFromCenter = math.sqrt(dx * dx + dy * dy);
                  const deadZoneRadius = 40.0;
                  if (distanceFromCenter < deadZoneRadius) return;

                  const startAngle = 0.75 * math.pi;
                  const sweep = 1.5 * math.pi;

                  double angle = math.atan2(dy, dx);
                  if (angle < 0) angle += 2 * math.pi;

                  double normalizedAngle = angle - startAngle;
                  if (normalizedAngle < 0) normalizedAngle += 2 * math.pi;

                  if (normalizedAngle > sweep) return;

                  double ratio = normalizedAngle / sweep;

                  // If close to 100%, round it to avoid float inaccuracies
                  if (ratio > 0.995) ratio = 1.0;
                  ratio = ratio.clamp(0.0, 1.0);

                  setState(() {
                    _dragTargetRatio = ratio;
                  });
                },
                onPanEnd: (_) async {
                  if (_dragTargetRatio == null) return;

                  final target = (_dragTargetRatio! * bi.capacity).toInt();
                  final info = await _batteryService.setTargetSOC(
                    widget.battery.houseId,
                    int.parse(widget.battery.deviceId),
                    target,
                  );

                  if (!mounted) return;
                  setState(() {
                    batInfo = info;
                    _isDragging = false;
                    _dragTargetRatio = null;
                  });
                },
                child: Listener(
                  onPointerUp: (puEvent) async {
                    final dx = puEvent.localPosition.dx - 100;
                    final dy = puEvent.localPosition.dy - 170;
                    final angle = 0.75 * math.pi - math.atan2(-dx, -dy);

                    if (angle < 0 || angle > 1.50 * math.pi) {
                      final info = await _batteryService.unsetTargetSOC(0, 0);
                      if (!mounted) return;

                      setState(() {
                        batInfo = info;
                      });
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.battery_full,
                        size: 150,
                        color: Theme.of(context).colorScheme.primaryFixedDim,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(100 * bi.stateOfCharge / bi.capacity).toInt()}%',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontSize: 25, color: Theme.of(context).colorScheme.onPrimaryFixed),
                          ),
                          if (_isDragging && _dragTargetRatio != null)
                            Text(
                              '${context.l10n.target}:\n${(100 * _dragTargetRatio!).toInt()}%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryFixed),
                              textAlign: TextAlign.center,
                            )
                          else if (bi.targetSoc != null)
                            Text(
                              '${context.l10n.target}:\n${(100 * bi.targetSoc! / bi.capacity).toInt()}%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryFixed),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                      CustomPaint(
                        size: Size(200, 200),
                        painter: BatteryRingPainter(
                          context,
                          bi.stateOfCharge / bi.capacity,
                          _dragTargetRatio ??
                              (bi.targetSoc != null
                                  ? bi.targetSoc! / bi.capacity
                                  : null),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.bolt),
                  Flexible(child: Text(batteryStatusString(bi))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the relevant status string for the battery.
  ///
  /// The status string specifies whether the battery is charging, discharging, or idle.
  /// If there is no target set it also displays a rough estimate of time till the battery if empty/full.
  /// No estimate is calculated if a target is set as the battery behaviour is too unpredictable.
  String batteryStatusString(BatteryInfo batInfo) {
    switch (batInfo.status) {
      case BatteryStatus.idle:
        return '${context.l10n.batteryIsIdle}.';
      case BatteryStatus.discharging:
        if (batInfo.targetSoc != null) {
          return '${context.l10n.batteryIsDischarging}.';
        }

        int time =
            (3600 * (batInfo.stateOfCharge) / batInfo.consumption).toInt();
        String timeString = '${time % 60} s';

        if (time >= 60) {
          time ~/= 60;
          timeString = '${time % 60} m $timeString';
        }

        if (time >= 60) {
          time ~/= 60;
          timeString = '${time % 60} h $timeString';
        }

        return '${context.l10n.batteryIsDischarging}, ${context.l10n.estimatedTimeTillEmpty(timeString)}.';
      case BatteryStatus.charging:
        if (batInfo.targetSoc != null) {
          return context.l10n.batteryIsCharging;
        }

        int time =
            (3600 *
                    (batInfo.capacity - batInfo.stateOfCharge) /
                    batInfo.consumption)
                .toInt();
        String timeString = '${time % 60} s';

        if (time >= 60) {
          time ~/= 60;
          timeString = '${time % 60} m $timeString';
        }

        if (time >= 60) {
          time ~/= 60;
          timeString = '${time % 60} h $timeString';
        }

        return '${context.l10n.batteryIsCharging}, ${context.l10n.estimatedTimeTillFullCharge(timeString)}.';
    }
  }
}
