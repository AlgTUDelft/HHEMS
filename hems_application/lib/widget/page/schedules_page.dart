// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/util/timeshifter_util.dart';
import 'package:hems_app/widget/page/create_job.dart';
import 'package:hems_app/widget/scheduled_job.dart';
import 'package:hems_app/widget/schedule_view.dart';

/// A widget that displays upcoming scheduled jobs for timeshifter devices.
///
/// This widget shows a list of jobs associated with devices that can be scheduled,
/// grouped by date. It also shows suggestions for better scheduling (e.g., based on solar usage).
///
/// A [FloatingActionButton] allows users to create and schedule new jobs. Jobs are fetched
/// periodically (every 5 seconds) from the backend using [TimeshifterUtil].
class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => SchedulesPageState();
}

class SchedulesPageState extends State<SchedulesPage> {
  Timer? timer;
  List<DisplayJob> jobs = [];


  /// Initializes the widget state and starts a periodic timer to refresh the schedule list.
  @override
  void initState() {
    super.initState();
    loadTimeShifter();
    timer = Timer.periodic(
      Duration(seconds: 5),
      (Timer t) => loadTimeShifter(),
    );
  }

  /// Fetches the current house time and all scheduled jobs for timeshifter devices, and updates the display list.
  Future<void> loadTimeShifter() async {
    List<DisplayJob> newJobs = [];

    newJobs = await TimeshifterUtil().loadJobs(context) ?? [];

    if (!mounted) return;
    setState(() {
      jobs = newJobs;
    });
  }

  /// Disposes the page.
  ///
  /// In addition cancels the refresh timer.
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void cancelJob(int jobId, DateTime startTime, Device device) async {
    await TimeshifterUtil().cancelJob(context, jobId, startTime, device);

    // Reload jobs
    loadTimeShifter();
  }

  /// Builds the widget tree.
  ///
  /// Displays:
  /// - A list of upcoming jobs grouped by date.
  /// - Suggested changes for improving efficiency.
  /// - A [FloatingActionButton] to add a new job, which opens [CreateJob].
  ///
  /// If a job is created, it's immediately scheduled and the list is refreshed.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Text(
              context.l10n.comingUp,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ScheduleView(jobs: jobs, onCancelJob: cancelJob, height: 300),
            // Suggested optimization card
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.suggestedChanges,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "${context.l10n.ifMoveRuleFromToMoreUseOf(context.l10n.solarPanels, "18:00", "16:00")}.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: ScheduledJob(
                        id: -1,
                        onCancelJob: (id, startTime, device) {},
                        device: AppState().devices.firstWhere(
                          (device) => device.type == DeviceType.timeshifter,
                          orElse:
                              () => Device(
                                deviceId: context.l10n.exampleDevice,
                                houseId: 0,
                                type: DeviceType.timeshifter,
                              ),
                        ),
                        room: AppState().othersRoom(context),
                        startTime: DateTime.now().add(
                          Duration(days: 1, hours: 2, minutes: 30),
                        ),
                        endTime: DateTime.now().add(
                          Duration(days: 1, hours: 3, minutes: 30),
                        ),
                        displayTimeLeft: false,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FilledButton(
                            child: Text("${context.l10n.moveTo} 16:00"),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 60),
          ],
        ),

        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton.extended(
            label: Text(context.l10n.newJob),
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateJob()),
              ).then((newJob) async {
                if (newJob != null && newJob is DisplayJob) {
                  // Reload jobs
                  loadTimeShifter();
                }
              });
            },
          ),
        ),
      ],
    );
  }
}
