import 'package:either_dart/either.dart';
import 'package:hems_app/model/api/device_status.dart';
import 'package:hems_app/model/api/schedule_job.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/service/timeshifter_service.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/util/timeshifter_util.dart';
import 'package:hems_app/widget/schedule_view.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Integration tests',
    () {
    test('List jobs', () async {
      AppState appState = AppState();

      Device device = Device(
        houseId: 0,
        deviceId: "DishWasher",
        type: DeviceType.timeshifter,
      );
      Room room = Room(
        type: RoomType.bathroom,
        name: "Bathroom",
        devices: [device],
      );
      appState.devices = [device];
      appState.rooms = [room];

      // Clear any existing jobs to avoid conflicts
      List<DisplayJob>? jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      while (jobs != null && jobs.isNotEmpty) {
        await TimeshifterUtil().cancelJob(null, jobs.first.id, jobs.first.startTime, device);
        jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      }

      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 0);

      DisplayJob job = DisplayJob(
        id: -1,
        startTime: DateTime.now().add(Duration(hours: 1)),
        duration: Duration(hours: 3),
        device: device,
        room: room,
      );

      await TimeshifterService().scheduleJob(
        0,
        device.deviceId,
        ScheduleJob(3600, 10800)
      );

      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 1);
      expect(jobs.first.duration, job.duration);
      expect(jobs.first.room, room);
      expect(jobs.first.device, device);
    });

    test('Jobs are filtered correctly', () async {
      AppState appState = AppState();

      Device device = Device(
        houseId: 0,
        deviceId: "DishWasher",
        type: DeviceType.timeshifter,
      );
      Room room = Room(
        type: RoomType.bathroom,
        name: "Bathroom",
        devices: [device],
      );
      appState.devices = [device];
      appState.rooms = [room];

      // Clear any existing jobs to avoid conflicts
      List<DisplayJob>? jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      while (jobs != null && jobs.isNotEmpty) {
        await TimeshifterUtil().cancelJob(null, jobs.first.id, jobs.first.startTime, device);
        jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      }

      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 0);

      DisplayJob job = DisplayJob(
        id: -1,
        startTime: DateTime.now().add(Duration(seconds: 100000)),
        duration: Duration(hours: 3),
        device: device,
        room: room,
      );

      await TimeshifterService().scheduleJob(
        0,
        device.deviceId,
        ScheduleJob(3600, 10800)
      );

      await TimeshifterService().scheduleJob(
        0,
        device.deviceId,
        ScheduleJob(100000, 10800)
      );

      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId, now: DateTime.now().add(Duration(hours: 5)));
      expect(jobs, isNotNull);
      expect(jobs!.length, 1);
      expect(jobs.first.duration, job.duration);
      expect(jobs.first.room, room);
      expect(jobs.first.device, device);
    });

    test('Jobs are sorted correctly', () async {
      AppState appState = AppState();

      Device device = Device(
        houseId: 0,
        deviceId: "DishWasher",
        type: DeviceType.timeshifter,
      );
      Room room = Room(
        type: RoomType.bathroom,
        name: "Bathroom",
        devices: [device],
      );
      appState.devices = [device];
      appState.rooms = [room];

      // Clear any existing jobs to avoid conflicts
      List<DisplayJob>? jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      while (jobs != null && jobs.isNotEmpty) {
        await TimeshifterUtil().cancelJob(null, jobs.first.id, jobs.first.startTime, device);
        jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      }

      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 0);

      await TimeshifterService().scheduleJob(
        0,
        device.deviceId,
        ScheduleJob(10000, 10800)
      );

      await TimeshifterService().scheduleJob(
        0,
        device.deviceId,
        ScheduleJob(500000, 15800)
      );

      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 2);
      expect(jobs.first.duration, Duration(seconds: 10800));
      expect(jobs.first.room, room);
      expect(jobs.first.device, device);
      expect(jobs[1].duration, Duration(seconds: 15800));
      expect(jobs[1].room, room);
      expect(jobs[1].device, device);
    });

    test('Cancel jobs', () async {
      AppState appState = AppState();

      Device device = Device(
        houseId: 0,
        deviceId: "DishWasher",
        type: DeviceType.timeshifter,
      );
      Room room = Room(
        type: RoomType.bathroom,
        name: "Bathroom",
        devices: [device],
      );
      appState.devices = [device];
      appState.rooms = [room];

      // Clear any existing jobs to avoid conflicts
      List<DisplayJob>? jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      while (jobs != null && jobs.isNotEmpty) {
        await TimeshifterUtil().cancelJob(null, jobs.first.id, jobs.first.startTime, device);
        jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      }

      await TimeshifterService().scheduleJob(
        0,
        device.deviceId,
        ScheduleJob(3600, 10800)
      );

      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 1);

      await TimeshifterService().scheduleJob(
        0,
        device.deviceId,
        ScheduleJob(20000, 10800)
      );

      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 2);

      await TimeshifterUtil().cancelJob(null, jobs.first.id, jobs.first.startTime, device);
      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 1);

      await TimeshifterUtil().cancelJob(null, jobs.first.id, jobs.first.startTime, device);
      jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      expect(jobs, isNotNull);
      expect(jobs!.length, 0);
    });

    test("Schedule job", () async {
      AppState appState = AppState();

      Device device = Device(
        houseId: 0,
        deviceId: "DishWasher",
        type: DeviceType.timeshifter,
      );
      Room room = Room(
        type: RoomType.bathroom,
        name: "Bathroom",
        devices: [device],
      );
      appState.devices = [device];
      appState.rooms = [room];

      // Clear any existing jobs to avoid conflicts
      List<DisplayJob>? jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      while (jobs != null && jobs.isNotEmpty) {
        await TimeshifterUtil().cancelJob(null, jobs.first.id, jobs.first.startTime, device);
        jobs = await TimeshifterUtil().loadJobs(null, deviceId: device.deviceId);
      }

      DisplayJob job = DisplayJob(
        id: -1,
        startTime: DateTime.now().add(Duration(hours: 1)),
        duration: Duration(hours: 3),
        device: device,
        room: room,
      );

      await TimeshifterUtil().scheduleJob(null, job);

      Either<DeviceStatus, String> result = await TimeshifterService().getTimeshifterProperties(device.houseId, device.deviceId);
      expect(result.isLeft, true);
      final deviceStatus = result.left;
      expect(deviceStatus.scheduledJobs.length, 1);
      expect(deviceStatus.scheduledJobs.first.endTime - deviceStatus.scheduledJobs.first.startTime, job.duration.inSeconds);

    });
  },
  tags: ['integration'], 
  skip:
      const bool.hasEnvironment('HEMS_URL')
          ? false
          : 'HEMS_URL not set, skipping integration test',)
  ;
}