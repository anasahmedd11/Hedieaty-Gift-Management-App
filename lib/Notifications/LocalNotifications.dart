import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // Android settings
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('flutter_logo');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await notificationsPlugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
      const AndroidNotificationChannel androidChannel =
          AndroidNotificationChannel(
        'your_channel_id',
        'your_channel_name',
        description: 'This is the description of your channel',
        importance: Importance.high,
      );
      notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      await notificationDetails(),
    );
  }
}
