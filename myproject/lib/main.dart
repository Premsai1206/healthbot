import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myproject/Login/SplashScreen.dart';
import 'package:myproject/Login/homepage.dart';
import 'package:myproject/Notifications/local_notifications.dart';
import 'package:myproject/Login/login.dart';
import 'package:myproject/Login/wrapper.dart';

import 'package:timezone/data/latest_10y.dart';
import 'BloodDonor/DonationForm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotifications.init();
  initializeTimeZones();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
       // Set the initial route
      routes: {
        '/bloodDonationForm': (context) => DonationForm(),
        '/home': (context)=> Homepage(),
        '/login': (context)=> Login(),

        // You can add more routes here if needed
      },


      home: SplashScreen(),
    );
  }
}
