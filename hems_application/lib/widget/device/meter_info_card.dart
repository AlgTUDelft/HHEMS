import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/api/meter_info.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/service/meter_service.dart';
import 'package:hems_app/widget/util/value_row.dart';

class MeterInfoCard extends StatefulWidget {
  final Device meter;
  const MeterInfoCard({required this.meter, super.key});

  @override
  State<MeterInfoCard> createState() => MeterInfoState();
}

class MeterInfoState extends State<MeterInfoCard> {
  Either<MeterInfo, String>? meterInfo;
  Timer? timer;
  final _meterService = MeterService();

  /// Initializes the meter info card widget.
  ///
  /// In addition, starts a timer to refresh the widget every 5 seconds.
  @override
  void initState() {
    super.initState();
    loadMeter();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => loadMeter());
  }

  /// Updates the widget with new meter information.
  Future<void> loadMeter() async {
    final info = await _meterService.getMeterInfo(
      widget.meter.houseId,
      int.parse(widget.meter.deviceId),
    );
    if (!mounted) return;
    setState(() {
      meterInfo = info;
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
  /// If [meterInfo] is not loaded yet it shows a progress indicator.
  /// If there was an error during loading [meterInfo] it shows the relevant error message.
  /// Otherwise it displays the current import/export in W and total import and export in Wh.
  @override
  Widget build(BuildContext context) {
    if (meterInfo == null) return Center(child: CircularProgressIndicator());
    if (meterInfo!.isRight) return Center(child: Text(meterInfo!.right));
    MeterInfo mi = meterInfo!.left;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.meterInfo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  if (mi.currentExport != null && mi.currentExport! > 0)
                    ValueRow(
                      description: '${context.l10n.currentExport}:',
                      value: '${mi.currentExport!.toStringAsFixed(2)} W',
                      icon: Icons.bolt,
                    )
                  else
                    ValueRow(
                      description: '${context.l10n.currentImport}:',
                      value: '${(mi.currentImport ?? 0).toStringAsFixed(2)} W',
                      icon: Icons.bolt,
                    ),
                  Divider(),
                  ValueRow(
                    description: '${context.l10n.totalExport}:',
                    value: '${mi.totalExport.toStringAsFixed(2)} Wh',
                    icon: Icons.bolt,
                  ),

                  Divider(),
                  ValueRow(
                    description: '${context.l10n.totalImport}:',
                    value: '${mi.totalImport.toStringAsFixed(2)} Wh',
                    icon: Icons.bolt,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
