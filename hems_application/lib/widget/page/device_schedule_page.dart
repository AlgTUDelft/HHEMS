import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/util/timeshifter_util.dart';
import 'package:hems_app/widget/page/create_job.dart';
import 'package:hems_app/widget/schedule_view.dart';

/// Page where the user can view the job schedule for a specific timeshifter device only.
/// 
/// Jobs are fetched periodically (every 5 seconds) from the backend using [TimeshifterUtil].
class DeviceSchedulePage extends StatefulWidget {
  const DeviceSchedulePage({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<DeviceSchedulePage> createState() => DeviceSchedulePageState();
}

class DeviceSchedulePageState extends State<DeviceSchedulePage> {
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

    newJobs = await TimeshifterUtil().loadJobs(context, deviceId: widget.deviceId) ?? [];

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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 10),
        Text(context.l10n.scheduleForDevice(widget.deviceId),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center),
        SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ScheduleView(
                jobs: jobs,
                onCancelJob: cancelJob,
              ),
            ),
          ),
        SizedBox(height: 10),
        FilledButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateJob(initialDevice: AppState().devices.firstWhere(
                (d) => d.deviceId == widget.deviceId,
              ),
              ),
            ),
          ).then((newJob) {
            loadTimeShifter();
          });
        }, child: Text(context.l10n.createNewJob)),
        SizedBox(height: 10),
      ],
    );
  }
}