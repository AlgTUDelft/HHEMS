// ignore_for_file: use_build_context_synchronously

import 'package:duration_picker/duration_picker.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/api/device_status.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/service/timeshifter_service.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/util/timeshifter_util.dart';
import 'package:hems_app/widget/page/device_selection_page.dart';
import 'package:hems_app/widget/schedule_view.dart';

/// Page for creating(scheduling) jobs for timeshifter devices.
///
/// The minimum duration field currently acts as a way to avoid request errors from the backend,
/// since some devices can only be scheduled for a minimum time.
/// [initialDevice] can optionally be set to pre-select a device.
class CreateJob extends StatefulWidget {
  const CreateJob({super.key, this.initialDevice});

  final Device? initialDevice;

  @override
  State<CreateJob> createState() => CreateJobState();
}

class CreateJobState extends State<CreateJob> {
  Device? device;
  Room? _room;
  DateTime? _date;
  TimeOfDay? _time;
  Duration? _duration;
  Duration? minimumDuration;

  /// Fetch the minimum job duration and room for the initial device, if it is set.
  @override
  void initState() {
    super.initState();
    device = widget.initialDevice;
    if (device != null) {
      minimumDuration = Duration(seconds: 30);
      TimeshifterService().getTimeshifterProperties(
        device!.houseId,
        device!.deviceId,
      ).then((status) {
        if (status.isLeft) {
          setState(() {
            minimumDuration = status.left.minimumJobDuration;
          });
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${context.l10n.errorFetchingDeviceStatus}: ${status.right}",
                ),
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createNewJob)),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    FilledButton.tonal(
                      onPressed: () async {
                        var data = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceSelectionPage(),
                          ),
                        );
                        if (data == null) return;
                        var selectedDevice = data["device"];
                        var room = data["room"];
                        if (selectedDevice != null) {
                          setState(() {
                            device = selectedDevice;
                            _room = room;
                            // Reset minimum duration until we've fetched the new minimum.
                            minimumDuration = null;
                          });
                        }
                        // Get device status
                        Either<DeviceStatus, String> status =
                            await TimeshifterService().getTimeshifterProperties(
                              device!.houseId,
                              device!.deviceId,
                            );
                        if (status.isLeft) {
                          setState(() {
                            minimumDuration = status.left.minimumJobDuration;
                          });
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${context.l10n.errorFetchingDeviceStatus}: ${status.right}",
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 20.0,
                        ),
                        child:
                            device == null
                                ? Column(
                                  children: [
                                    Text(
                                      context.l10n.device,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    Center(
                                      child: Text(
                                        context.l10n.selectADevice,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  children: [
                                    Text(
                                      context.l10n.device,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    Center(
                                      child: Text(
                                        device!.deviceId,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {
                              final DateTime firstDate = DateTime.now();
                              final DateTime lastDate = DateTime.now().add(
                                Duration(days: 365),
                              );
                              showDatePicker(
                                context: context,
                                firstDate: firstDate,
                                lastDate: lastDate,
                                initialDate: _date ?? DateTime.now(),
                              ).then(
                                (date) => setState(() {
                                  _date = date;
                                }),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 20.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    context.l10n.date,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  Center(
                                    child: Text(
                                      _date?.toLocal().toString().split(
                                            ' ',
                                          )[0] ??
                                          context.l10n.selectADate,
                                      textAlign: TextAlign.center,
                                      style: _date == null ? null : TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {
                              showTimePicker(
                                context: context,
                                initialTime: _time ?? TimeOfDay.now(),
                              ).then(
                                (time) => setState(() {
                                  _time = time;
                                }),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 20.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    context.l10n.startTime,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  Center(
                                    child: Text(
                                      _time?.format(context) ??
                                          context.l10n.selectATime,
                                      textAlign: TextAlign.center,
                                      style: _time == null ? null : TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    FilledButton.tonal(
                      onPressed:
                          device == null || minimumDuration == null
                              ? null
                              : () {
                                showDurationPicker(
                                  context: context,
                                  initialTime: _duration ?? minimumDuration!,
                                  lowerBound: minimumDuration!,
                                  baseUnit: BaseUnit.minute,
                                ).then(
                                  (duration) => setState(() {
                                    if (duration == null ||
                                        duration.isNegative ||
                                        duration.inMinutes == 0) {
                                      return;
                                    }
                                    if (duration < minimumDuration!) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).removeCurrentSnackBar();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "${context.l10n.durationAtLeastHoursMinutes(minimumDuration!.inHours, minimumDuration!.inMinutes.remainder(60))}.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    _duration = duration;
                                  }),
                                );
                              },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          children: [
                            Text(
                              context.l10n.duration,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            Center(
                              child: Text(
                                _duration == null
                                  ? (device == null ? context.l10n.selectDeviceFirst : context.l10n.selectADuration)
                                  : "${_duration!.inHours}h ${_duration!.inMinutes.remainder(60)}m",
                                style: device == null ? TextStyle(color: Theme.of(context).colorScheme.error) : (_duration == null ? null : TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed:
                    (device == null ||
                            _date == null ||
                            _time == null ||
                            _duration == null)
                        ? null
                        : () async {
                          _room ??= AppState().rooms.firstWhere(
                              (r) => r.devices.any((d) => d.deviceId == device?.deviceId),
                              orElse: () => AppState().othersRoom(context),
                            );

                          DateTime startTime = DateTime(
                            _date!.year,
                            _date!.month,
                            _date!.day,
                            _time!.hour,
                            _time!.minute,
                          );
                          // Make sure the start time is not in the past
                          // Subtract 1 minute from the start time to avoid issues when the start time is in the same minute as the current time
                          if (startTime
                              .add(Duration(minutes: -1))
                              .isBefore(DateTime.now())) {
                            ScaffoldMessenger.of(
                              context,
                            ).removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.startTimeCantBeInThePast,
                                ),
                              ),
                            );
                            return;
                          }
                          if (_duration! < minimumDuration!) {
                            ScaffoldMessenger.of(
                              context,
                            ).removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${context.l10n.durationAtLeastHoursMinutes(minimumDuration!.inHours, minimumDuration!.inMinutes.remainder(60))}.",
                                ),
                              ),
                            );
                            return;
                          }

                          DisplayJob newJob = DisplayJob(
                            id: -1,
                            room: _room!,
                            device: device!,
                            startTime: startTime,
                            duration: _duration!,
                          );

                          await TimeshifterUtil().scheduleJob(context, newJob);

                          if (context.mounted) {
                            Navigator.pop(
                              context,
                              newJob,
                            );
                          }
                        },
                child: Text(context.l10n.createJob),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
