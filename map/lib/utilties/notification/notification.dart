import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

   static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

   static init() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('ic_launcher');


    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: 'channel description',
            importance: Importance.max,icon: "ic_launcher",
            largeIcon: DrawableResourceAndroidBitmap("ic_launcher"),
            priority: Priority.max,
            showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        0, '가게 도착', '목적지에 도착했습니다.', notificationDetails);

    //await flutterLocalNotificationsPlugin.cancel(0); 아이디가 0인 알람 삭제
  }


  static Future<PermissionStatus> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status;
  }


}
