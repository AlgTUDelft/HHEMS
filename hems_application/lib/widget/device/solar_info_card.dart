import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/api/solar_info.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/service/solar_service.dart';
import 'package:hems_app/widget/util/value_row.dart';

import 'solar_toggle_switch.dart';

class SolarInfoCard extends StatefulWidget {
  final Device solarPanel;
  const SolarInfoCard({required this.solarPanel, super.key});

  @override
  State<SolarInfoCard> createState() => SolarInfoState();
}

class SolarInfoState extends State<SolarInfoCard> {
  Either<SolarInfo, String>? solarInfo;
  Timer? timer;
  final _solarService = SolarService();

  /// Initialzes the solar info card widget.
  ///
  /// In addition, starts a timer to refresh the widget every 5 seconds.
  @override
  void initState() {
    super.initState();
    loadSolar();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => loadSolar());
  }

  /// Updates the widget with new solar information.
  Future<void> loadSolar() async {
    final info = await _solarService.getSolarInfo(
      widget.solarPanel.houseId,
      int.parse(widget.solarPanel.deviceId),
    );
    if (!mounted) return;
    setState(() {
      solarInfo = info;
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
  /// If [solarInfo] is not loaded yet it shows a progress indicator.
  /// If there was an error during loading [solarInfo] it shows the relevant error message.
  /// Otherwise it displays the production of the solar panel in W.
  @override
  Widget build(BuildContext context) {
    if (solarInfo == null) return Center(child: CircularProgressIndicator());
    if (solarInfo!.isRight) return Center(child: Text(solarInfo!.right));
    SolarInfo si = solarInfo!.left;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    context.l10n.solarPanel,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Flexible(child: SizedBox(width: 8)),
                SolarToggleSwitch(solarPanel: widget.solarPanel),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  ValueRow(
                    description: '${context.l10n.production}: ',
                    value: '${si.consumption.toStringAsFixed(2)} W',
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
