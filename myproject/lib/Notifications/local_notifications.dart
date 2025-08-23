import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
class LocalNotifications{
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotication = BehaviorSubject<String>();

  static void onNotificationTap(
      NotificationResponse notificationResponse
      ){
    onClickNotication.add(notificationResponse.payload!);
  }
  static Future init()async{

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
    onDidReceiveBackgroundNotificationResponse: onNotificationTap);


  }

 static void checkForNotification()async{
    NotificationAppLaunchDetails? details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if(details!= null){
      if(details.didNotificationLaunchApp){
        NotificationResponse? res = details.notificationResponse;

        if(res!=null){
          String? payload = res.payload;
          print('Notification $payload');
        }
      }
    }
  }




}