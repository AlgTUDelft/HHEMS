import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/api/device_status.dart';
import 'package:hems_app/model/api/job.dart';
import 'package:hems_app/service/timeshifter_service.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/page/create_job.dart';
import 'package:hems_app/widget/page/device_schedule_page.dart';

class TimeshifterCard extends StatefulWidget {
  final String deviceId;

  const TimeshifterCard(this.deviceId, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<TimeshifterCard> createState() => TimeshifterState(deviceId);
}

class TimeshifterState extends State<TimeshifterCard> {
  Either<DeviceStatus, String>? deviceStatus;
  Timer? timer;
  final _timeshifterService = TimeshifterService();
  final String deviceId;
  // The delay between the current time and the time of the house.
  // Can be different from 0 if we're out of sync or if the house is a simulation.
  int timeDelay = 0;

  TimeshifterState(this.deviceId);

  /// Initializes the time shifter card widget.
  ///
  /// In addition, starts a timer to refresh the widget every 5 seconds.
  @override
  void initState() {
    super.initState();
    loadTimeShifter();
    timer = Timer.periodic(
      Duration(seconds: 5),
      (Timer t) => loadTimeShifter(),
    );
  }

  /// Updates the widget with new meter information.
  Future<void> loadTimeShifter() async {
    final status = await _timeshifterService.getTimeshifterProperties(
      0,
      deviceId,
    );

    final currentTime = await _timeshifterService.getCurrentHouseTime(0);
    if (currentTime.isLeft) {
      timeDelay =
          int.parse(currentTime.left) -
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } else {
      timeDelay = 0; // Default to 0 if we can't get the current time.
    }

    if (!mounted) return;
    setState(() {
      deviceStatus = status;
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
  /// If [deviceStatus] is not loaded yet it shows a progress indicator.
  /// If there was an error during loading [deviceStatus] it shows the relevant error message.
  /// Otherwise it displays the date of the schedule and the amount of time it will run.
  @override
  Widget build(BuildContext context) {
    if (deviceStatus == null) return Center(child: CircularProgressIndicator());
    if (deviceStatus!.isRight) return Center(child: Text(deviceStatus!.right));
    DeviceStatus ds = deviceStatus!.left;

    if (ds.scheduledJobs.isEmpty) {
      return noScheduledDevice(ds, context);
    }

    Job nextJob = ds.scheduledJobs[0];

    // Calculate the time now in seconds.
    DateTime startTime = DateTime.fromMillisecondsSinceEpoch(
      nextJob.startTime * 1000 - timeDelay * 1000,
    );
    DateTime endTime = DateTime.fromMillisecondsSinceEpoch(
      nextJob.endTime * 1000 - timeDelay * 1000,
    );
    Duration untilJob = startTime.difference(DateTime.now());
    Duration duration = Duration(seconds: nextJob.endTime - nextJob.startTime);
    Duration timeLeft = endTime.difference(DateTime.now());

    if (timeLeft.isNegative) {
      return noScheduledDevice(ds, context);
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deviceId,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (startTime.isAfter(DateTime.now())) Icon(Icons.event, size: 65)
                else Icon(Icons.timer_sharp, size: 65),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        ((startTime.isAfter(DateTime.now()))
                            ? [
                              Text(
                                context.l10n.nextScheduledActionStartsIn(
                                  untilJob.inHours,
                                  untilJob.inMinutes - untilJob.inHours * 60,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                context.l10n.durationHoursMinutes(
                                  duration.inHours,
                                  duration.inMinutes - duration.inHours * 60,
                                ),
                              ),
                            ]
                            : [
                              Text(context.l10n.jobCurrentlyActive),
                              SizedBox(height: 5),
                              Text(
                                context.l10n.timeLeftHoursMinutes(
                                  timeLeft.inHours,
                                  timeLeft.inMinutes - timeLeft.inHours * 60,
                                ),
                              ),
                            ])
                            + [
                                SizedBox(height: 10),
                                OutlinedButton(
                                  child: Text(context.l10n.viewSchedule),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      showDragHandle: true,
                                      builder: (context) {
                                        return DeviceSchedulePage(deviceId: deviceId);
                                      }
                                    ).then((_) {
                                      // Refresh the device status
                                      loadTimeShifter();
                                    });
                                  }
                                )
                              ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card used to display Timeshifter without a scheduled job.
  Card noScheduledDevice(DeviceStatus ds, BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deviceId,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_today, size: 65),
                SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${context.l10n.thereAreNoScheduledJobsForThisDevice}.",
                      ),
                      SizedBox(height: 10),
                        OutlinedButton(child: Text(context.l10n.scheduleAJob), onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateJob(initialDevice: AppState().devices.firstWhere(
                                (d) => d.deviceId == deviceId,
                              ),
                              ),
                            ),
                          ).then((newJob) {
                            loadTimeShifter();
                          });
                        })
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
