// ignore_for_file: use_build_context_synchronously

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/api/device_status.dart';
import 'package:hems_app/model/api/schedule_job.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/service/local_notifications_service.dart';
import 'package:hems_app/service/timeshifter_service.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/schedule_view.dart';

/// Utility class for managing timeshifter jobs.
class TimeshifterUtil {
  /// Loads all jobs for timeshifter device, optionally filtered by [deviceId].
  ///
  /// Jobs that have already ended are removed from the list.
  /// This is determined by the current time, but that time can be overridden by passing [now].
  /// Jobs are also sorted by their starting time.
  ///
  /// If any request to the backend fails, an error message is shown in a SnackBar of the given [BuildContext].
  /// If [context] is null, no SnackBar is shown.
  Future<List<DisplayJob>?> loadJobs(
    BuildContext? context, {
    String? deviceId,
    DateTime? now,
  }) async {
    List<DisplayJob> newJobs = [];
    int timeDelay = 0;

    now ??= DateTime.now();

    var timeshifters =
        AppState().devices
            .where((device) => device.type == DeviceType.timeshifter)
            .where((device) => deviceId == null || device.deviceId == deviceId)
            .toList();
    if (timeshifters.isEmpty) {
      return [];
    }

    final currentTime = await TimeshifterService().getCurrentHouseTime(0);
    if (currentTime.isLeft) {
      timeDelay =
          int.parse(currentTime.left) -
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } else {
      timeDelay = 0;
    }

    for (Device device in timeshifters) {
      Either<DeviceStatus, String> deviceStatusResult =
          await TimeshifterService().getTimeshifterProperties(
            device.houseId,
            device.deviceId,
          );

      if (deviceStatusResult.isRight) {
        if (context?.mounted ?? false) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              content: Text(
                "${context.l10n.failedToGetStatusOf} ${device.deviceId}: ${deviceStatusResult.right}",
              ),
            ),
          );
        }
        continue;
      }

      DeviceStatus deviceStatus = deviceStatusResult.left;
      Room? deviceRoom = AppState().rooms.firstWhere(
        (room) => room.devices.contains(device),
        orElse:
            () =>
                context != null
                    ? AppState().othersRoom(context)
                    : Room(type: RoomType.others, name: "Others", devices: []),
      );

      for (int i = 0; i < deviceStatus.scheduledJobs.length; i++) {
        var job = deviceStatus.scheduledJobs[i];
        DateTime startTime = DateTime.fromMillisecondsSinceEpoch(
          job.startTime * 1000 - timeDelay * 1000,
        );
        DateTime endTime = DateTime.fromMillisecondsSinceEpoch(
          job.endTime * 1000 - timeDelay * 1000,
        );
        newJobs.add(
          DisplayJob(
            id: i,
            room: deviceRoom,
            device: device,
            startTime: startTime,
            duration: endTime.difference(startTime),
          ),
        );
      }
    }

    newJobs.sort((a, b) => a.startTime.compareTo(b.startTime));
    newJobs.removeWhere(
      (job) => job.startTime.add(job.duration).isBefore(now!),
    );

    return newJobs;
  }

  /// Cancels a job with the given [jobId] and [startTime] for the specified [device].
  ///
  /// If the cancellation is successful, a success message is shown in a SnackBar of the given [BuildContext].
  /// If the cancellation fails, an error message is shown instead.
  /// If [context] is null, no SnackBar is shown.
  ///
  /// This also cancels the corresponding notification for the job.
  /// The notification ID is derived from the device ID and the job's start time.
  /// If [context] is null, the notification is not cancelled. The value of [startTime] also becomes irrelevant in this case.
  Future<void> cancelJob(
    BuildContext? context,
    int jobId,
    DateTime startTime,
    Device device,
  ) async {
    if (context?.mounted ?? false) {
      ScaffoldMessenger.of(
        context!,
      ).showSnackBar(SnackBar(content: Text(context.l10n.cancelingJob)));
    }

    final result = await TimeshifterService().cancelJob(
      device.houseId,
      device.deviceId,
      jobId,
    );

    // Cancel notification
    if (context != null) {
      int notificationId =
          device.deviceId.hashCode + startTime.toUtc().millisecondsSinceEpoch;
      // Notification IDs have to be 32-bit so let's size it down
      notificationId =
          ((notificationId >>> 32) ^ notificationId) & ((1 << 31) - 1);
      LocalNotificationsService().cancelNotification(notificationId);
      LocalNotificationsService().cancelNotification(~notificationId);
    }

    if (context?.mounted ?? false) {
      ScaffoldMessenger.of(context!).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isLeft
                ? "${context.l10n.jobCancelledSuccessfully}!"
                : "${context.l10n.failedToCancelJob}: ${result.right}",
          ),
        ),
      );
    }
  }

  /// Schedules a job for a timeshifter device. Job parameters are taken from [job].
  ///
  /// All properties of [DisplayJob] are relevant, except for [DisplayJob.id] and [DisplayJob.room].
  /// If [context] is not null, SnackBars are shown that indicate the state of the scheduling.
  ///
  /// If the job is scheduled successfully, and [context] is not null, a reminder notification is scheduled for 10 minutes before the job starts.
  /// The notification is not set if the job's start time is less than 10 minutes away from the current time.
  /// The notification ID is derived from the device ID and the job's start time.
  Future<void> scheduleJob(BuildContext? context, DisplayJob job) async {
    // Send job to the backend
    if (context?.mounted ?? false) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text("${context.l10n.schedulingJob}...")),
      );
    }

    ScheduleJob scheduleJob = ScheduleJob(
      job.startTime.difference(DateTime.now()).inSeconds,
      job.duration.inSeconds,
    );

    final result = await TimeshifterService().scheduleJob(
      job.device.houseId,
      job.device.deviceId,
      scheduleJob,
    );

    if (result.isLeft) {
      /// Precise start/end times in milliseconds from backend
      int startTimeMilliseconds = result.left.startTime;
      int endTimeMilliseconds = result.left.endTime;

      /// Calculate timeDelay between simulation and actual time
      int timeDelay = 0;
      final currentTime = await TimeshifterService().getCurrentHouseTime(0);
      if (currentTime.isLeft) {
        timeDelay =
            int.parse(currentTime.left) -
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
      } else {
        timeDelay = 0;
      }

      /// Calculate precise start time and end time date
      DateTime preciseStartTime = DateTime.fromMillisecondsSinceEpoch(
        startTimeMilliseconds * 1000 - timeDelay * 1000,
      );
      DateTime preciseEndTime = DateTime.fromMillisecondsSinceEpoch(
        endTimeMilliseconds * 1000 - timeDelay * 1000,
      );

      // Check if the delay is more than 10 minutes. If so, schedule a reminder
      if ((context?.mounted ?? false) &&
          !preciseStartTime
              .add(Duration(minutes: -10))
              .isBefore(DateTime.now())) {
        String name = job.device.deviceId;
        final reminderTime = preciseStartTime.subtract(Duration(minutes: 10));

        // Schedule a reminder for 10 minutes before the device starts
        int notificationId =
            name.hashCode + preciseStartTime.toUtc().millisecondsSinceEpoch;

        // Notification IDs have to be 32-bit so let's size it down
        notificationId =
            ((notificationId >>> 32) ^ notificationId) & ((1 << 31) - 1);
        LocalNotificationsService().scheduleReminder(
          id: notificationId,
          title: context!.l10n.scheduleReminder,
          body: context.l10n.yourDeviceWillStartInTenMinutes(name),
          delay: reminderTime.difference(DateTime.now()),
        );
      }

      // Check if the delay is more than 10 minutes. If so, schedule a reminder
      if ((context?.mounted ?? false) &&
          !preciseEndTime
              .add(Duration(minutes: -10))
              .isBefore(DateTime.now())) {
        String name = job.device.deviceId;
        final reminderTime = preciseEndTime.subtract(Duration(minutes: 10));

        // Schedule a reminder for 10 minutes before the device stops
        int notificationId =
            name.hashCode + preciseStartTime.toUtc().millisecondsSinceEpoch;

        // Notification IDs have to be 32-bit so let's size it down
        notificationId =
            ((notificationId >>> 32) ^ notificationId) & ((1 << 31) - 1);

        LocalNotificationsService().scheduleReminder(
          id: ~notificationId,
          title: context!.l10n.scheduleReminder,
          body: context.l10n.yourDeviceWillStopInTenMinutes(name),
          delay: reminderTime.difference(DateTime.now()),
        );
      }

      if (context?.mounted ?? false) {
        ScaffoldMessenger.of(context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isLeft
                  ? "${context.l10n.jobScheduledSuccessfully}!"
                  : "${context.l10n.failedToScheduleJob}: ${result.right}",
            ),
          ),
        );
      }
    }
  }
}
