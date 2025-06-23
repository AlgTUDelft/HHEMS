import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:intl/intl.dart';

/// A widget that visually represents a scheduled job for a [Device] in a [Room].
///
/// The widget displays key information such as:
/// - The room the device belongs to, including its icon and color.
/// - The job's start and end times in the form of dates.
/// - The device ID and its icon.
/// - Whether the job is currently (supposed to be) running or not.
///
/// If [displayTimeLeft] is true, the start time is displayed to the left of the main card.
class ScheduledJob extends StatefulWidget {
  final int id;
  final Device device;
  final Room room;
  final DateTime startTime;
  final DateTime endTime;
  final bool displayTimeLeft;
  final Function(int id, DateTime startTime, Device device) onCancelJob;

  const ScheduledJob({
    super.key,
    required this.id,
    required this.device,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.displayTimeLeft,
    required this.onCancelJob,
  });

  @override
  State<ScheduledJob> createState() => _ScheduledJobState();
}

class _ScheduledJobState extends State<ScheduledJob> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    bool happening = widget.startTime.isBefore(DateTime.now()) &&
      widget.endTime.isAfter(DateTime.now());
    
    var box = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 270),
      child: AnimatedSize(
        curve: Curves.easeOut,
        duration: Duration(milliseconds: 100),
        child: Card(
          color: happening ? Theme.of(context).colorScheme.tertiaryContainer : Theme.of(context).colorScheme.primaryContainer,
          elevation: 2,
          child: InkWell(
            onTap:
                widget.id == -1
                    ? null
                    : () {
                      setState(() {
                        expanded = !expanded;
                      });
                    },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children:
                    <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Icon(
                                    widget.room.icon(),
                                    size: 24,
                                    color: widget.room.color(),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    widget.room.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.apply(color: widget.room.color()),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              DateFormat(
                                "HH:mm - dd MMMM",
                              ).format(widget.startTime),
                              style: Theme.of(context).textTheme.labelMedium,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          happening ? Container(width: 16, height: 16, decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle)) : SizedBox.shrink(),
                          happening ? SizedBox(width: 8) : SizedBox.shrink(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.device.deviceId,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  happening ? context.l10n.nowActiveUntil(DateFormat("HH:mm").format(widget.endTime)) : "${context.l10n.activeUntil} ${DateFormat("HH:mm").format(widget.endTime)}",
                                  style: happening ? Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onTertiaryContainer) : Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(widget.device.type.iconData, size: 24),
                        ],
                      ),
                    ] +
                    (expanded
                        ? <Widget>[
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FilledButton(
                                  onPressed: () {
                                    widget.onCancelJob(
                                      widget.id,
                                      widget.startTime,
                                      widget.device,
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.errorContainer,
                                    foregroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                  ),
                                  child: Text(context.l10n.cancelJob),
                                ),
                              ),
                            ],
                          ),
                        ]
                        : []),
              ),
            ),
          ),
        ),
      ),
    );

    return widget.displayTimeLeft
        ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 5),
            Text(
              DateFormat("HH:mm").format(widget.startTime),
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.right,
            ),
            SizedBox(width: 10),
            Flexible(child: box),
          ],
        )
        : box;
  }
}
