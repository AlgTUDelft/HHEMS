import 'package:firebase_messaging/firebase_messaging.dart';

/// Firebase service class for handling push notifications using [FirebaseMessaging] instance.
class FirebaseMsg {
  final msgService = FirebaseMessaging.instance;

  initFCM() async {
    await msgService.requestPermission();

    FirebaseMessaging.onBackgroundMessage(handleNotification);
    FirebaseMessaging.onMessage.listen(handleNotification);
  }
}

Future<void> handleNotification(RemoteMessage msg) async {}
