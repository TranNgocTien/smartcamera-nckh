import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Noti {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        new AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = new DarwinInitializationSettings();
    var initializationsSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  static Future showBigTextNotification(
      {var id = 0,
      required String title,
      required String body,
      var payload,
      required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails androidPlatformCHannelSpecifics =
        new AndroidNotificationDetails(
      'Smart camera',
      'channel_name',
      playSound: false,
      importance: Importance.max,
      priority: Priority.high,
    );
    var not = NotificationDetails(
        android: androidPlatformCHannelSpecifics,
        iOS: DarwinNotificationDetails());
    await fln.show(0, title, body, not);
  }
}
