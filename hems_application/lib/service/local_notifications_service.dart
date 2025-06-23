import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

/// Service class for sending instant notifications and scheduled notification.
class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Used to initialize settings for all supported platforms, as well as the icon for Android.
  Future<void> init() async {
    initializeTimeZones();

    setLocalLocation(getLocation('Europe/Brussels'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('icon_transparent');
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();
    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    const WindowsInitializationSettings windowsSettings =
        WindowsInitializationSettings(
          appName: 'Flutter Local Notifications Example',
          appUserModelId: 'Com.Dexterous.FlutterLocalNotificationsExample',
          // Search online for GUID generators to make your own
          guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
          linux: linuxSettings,
          windows: windowsSettings,
        );

    await notificationsPlugin.initialize(initializationSettings);
  }

  /// Sends instant notification to the device.
  ///
  /// Ids are unique for all notifications, on overlapping ids the latest takes priority.
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          channelDescription: 'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Sends scheduled notification to the device.
  ///
  /// Ids are unique for all notifications, on overlapping ids the latest takes priority.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    String? body,
    required Duration delay,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.linux) return;
    TZDateTime now = TZDateTime.now(local);
    TZDateTime scheduledDate = now.add(delay);
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'delay_notification_channel_id',
          'Delay Notifications',
          channelDescription: 'Delay notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Cancels the notification with the specified id.
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}
