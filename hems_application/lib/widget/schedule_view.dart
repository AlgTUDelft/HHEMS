import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/widget/scheduled_job.dart';
import 'package:intl/intl.dart';

/// A model representing a job that is scheduled for display purposes.
class DisplayJob {
  final int id;
  final Room room;
  final Device device;
  final DateTime startTime;
  final Duration duration;

  DisplayJob({
    required this.id,
    required this.room,
    required this.device,
    required this.startTime,
    required this.duration,
  });
}

/// A widget that displays a schedule for jobs, optionally filtered by a specific device.
/// 
/// The widget shows a list of [DisplayJob]s, each represented by a [ScheduledJob] widget.
/// If [height] is set, the widget will be fixed to that height.
/// [onCancelJob] is called when the user pressed the 'cancel' button on a job.
/// See [ScheduledJob] for more details on how each job is displayed.
class ScheduleView extends StatelessWidget {
  final List<DisplayJob> jobs;
  final Function(int id, DateTime startTime, Device device) onCancelJob;
  final double? height;

  const ScheduleView({
    super.key,
    required this.jobs,
    required this.onCancelJob,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
              elevation: 2,
              child: SizedBox(
                height: height,
                child:
                    jobs.isEmpty
                        ? Center(child: Text(context.l10n.noUpcomingJobs))
                        : ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: jobs.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  (jobs[0].startTime.day == DateTime.now().day && jobs[0].startTime.month == DateTime.now().month && jobs[0].startTime.year == DateTime.now().year) 
                                    ? SizedBox.shrink() : separator(jobs[0].startTime, context)
                                ],
                              );
                            }
                            var job = jobs[index - 1];
                            return ScheduledJob(
                              id: job.id,
                              onCancelJob:
                                  (id, startTime, device) =>
                                      onCancelJob(id, startTime, device),
                              device: job.device,
                              room: job.room,
                              startTime: job.startTime,
                              endTime: job.startTime.add(job.duration),
                              displayTimeLeft: true,
                            );
                          },
                          separatorBuilder: (context, index) {
                            if (index == 0) return SizedBox.shrink();
                            bool isNewDay =
                                jobs[index - 1].startTime.day !=
                                    jobs[index].startTime.day ||
                                jobs[index - 1].startTime.month !=
                                    jobs[index].startTime.month;
                            return isNewDay
                                ? separator(jobs[index].startTime, context)
                                : SizedBox.shrink();
                          },
                        ),
              ),
            );
  }

  Widget separator(DateTime startTime, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 10.0,
      ),
      child: Row(
        children: [
          Text(
            DateFormat(
              "dd MMMM",
            ).format(startTime),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}