import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/service/entity_service.dart';

class HaEntityInfoCard extends StatefulWidget {
  final Device entity;
  const HaEntityInfoCard({required this.entity, super.key});

  @override
  State<HaEntityInfoCard> createState() => HaEntityInfoCardState();
}

class HaEntityInfoCardState extends State<HaEntityInfoCard> {
  Either<Map<String, dynamic>, String>? entityState;
  Timer? timer;
  final _entityService = EntityService();

  /// Initialzes the home assistant entity info card widget.
  ///
  /// In addition, starts a timer to refresh the widget every 0.25 seconds.
  @override
  void initState() {
    super.initState();
    loadEntity();
    timer = Timer.periodic(
      Duration(milliseconds: 250),
      (Timer t) => loadEntity(),
    );
  }

  /// Updates the widget with new device information.
  Future<void> loadEntity() async {
    final info = await _entityService.getEntityState(
      widget.entity.houseId,
      widget.entity.deviceId,
    );
    if (!mounted) return;
    setState(() {
      entityState = info;
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
  /// If [entityState] is not loaded yet it shows a progress indicator.
  /// If there was an error during loading [entityState] it shows the relevant error message.
  /// If there are no errors it displays a switch that toggles the entity on and off.
  @override
  Widget build(BuildContext context) {
    if (entityState == null) return Center(child: CircularProgressIndicator());
    if (entityState!.isRight) return Center(child: Text(entityState!.right));
    Map<String, dynamic> es = entityState!.left;
    bool enabled = es["state"] == "on" ? true : false;
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
                    es["attributes"]["friendly_name"],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.08),
                    Switch(
                      value: enabled,
                      activeColor: Colors.green,
                      onChanged: (bool newEnabled) async {
                        final result = await _entityService.setEntityState(
                          widget.entity.houseId,
                          widget.entity.deviceId,
                          newEnabled,
                        );

                        if (!result.isLeft) {
                          return;
                        }

                        Map<String, dynamic>? newState =
                            (result.left as List<dynamic>).firstWhere(
                              (s) => s["entity_id"] == widget.entity.deviceId,
                              orElse: () => null,
                            );

                        if (newState == null) {
                          return;
                        }

                        setState(() {
                          if (!mounted) return;
                          entityState = Left(newState);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
