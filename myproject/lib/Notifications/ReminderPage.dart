import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'NotificationPage.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Map<String, bool> _notificationToggles = {};
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Initialize timezone
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set app bar background color to black
        title: Text(
          'Your Reminders',
          style: TextStyle(color: Colors.white), // Set app bar title color
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back button color to white
      ),
      backgroundColor: Colors.black, // Set page background color to black
      body: Column(
        children: [
          SizedBox(height: 20,),
          Container(
            width: 250,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Set button background color to grey
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0), // Set button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Set button border radius
                ),
                             ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, color: Colors.black), // Schedule reminder icon
                  SizedBox(width: 8.0), // Add spacing between icon and text
                  Text(
                    'Add a New Reminder',
                    style: TextStyle(
                      color: Colors.black, // Set text color to white
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Expanded(child: _buildReminderList()),
        ],
      ),
    );
  }

  Future<void> cancelNotifications(
      String medicationDetails, String dosage, List<dynamic> dayOfWeekList) async {
    List<String> selectedDaysList = dayOfWeekList.cast<String>();

    // Get existing notifications to cancel
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('reminders')
        .where('medicationDetails', isEqualTo: medicationDetails)
        .where('dosage', isEqualTo: dosage)
        .where('dayOfWeek', isEqualTo: selectedDaysList)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        var reminderId = doc['notificationId'];
        await flutterLocalNotificationsPlugin.cancel(reminderId);
      });
    });
  }

  Future<void> restartNotifications(
      String medicationDetails, String dosage, List<dynamic> dayOfWeekList) async {
    List<String> selectedDaysList = dayOfWeekList.cast<String>();

    // Get existing reminders data
    final remindersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('reminders')
        .where('medicationDetails', isEqualTo: medicationDetails)
        .where('dosage', isEqualTo: dosage)
        .where('dayOfWeek', isEqualTo: selectedDaysList)
        .get();

    // Loop through each reminder and schedule new notifications
    remindersSnapshot.docs.forEach((doc) async {
      var reminderId = doc['notificationId'];
      var reminderTime = (doc['reminderTime'] as Timestamp).toDate();

      // Schedule new notification using flutterLocalNotificationsPlugin
      await _scheduleNotification(reminderId, medicationDetails, dosage, reminderTime);
    });
  }

  Future<void> _scheduleNotification(
      int reminderId, String medicationDetails, String dosage, DateTime reminderTime) async {
    // Get the local timezone


    // Convert DateTime to TZDateTime
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    // Configure the notification
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,

    );

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminderId , // Use the existing reminderId
      'Reminder: $medicationDetails', // Title of the notification
      'Take $dosage', // Body of the notification
      scheduledDate, // Scheduled time as TZDateTime
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Widget _buildReminderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('reminders')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }
        final reminders = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final medicationDetails = reminders[index]['medicationDetails'];
            final dosage = reminders[index]['dosage'];
            final reminderTime = DateFormat.jm().format((reminders[index]['reminderTime'] as Timestamp).toDate());
            final List<dynamic> dayOfWeekList = reminders[index]['dayOfWeek'];
            final selectedDays = _getSelectedDays(dayOfWeekList);
            final bool notificationToggle = reminders[index]['notificationToggle'];

            return GestureDetector(
              onTap: () {
                String medicationDetails = reminders[index]['medicationDetails'];
                String dosage = reminders[index]['dosage'];
                DateTime reminderTime = (reminders[index]['reminderTime'] as Timestamp).toDate();
                List<dynamic> dayOfWeekList = reminders[index]['dayOfWeek'];
                Map<String, bool> selectedDays = {};
                for (var day in dayOfWeekList) {
                  selectedDays[day] = true;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(
                      medication: medicationDetails,
                      dosage: dosage,
                      reminderTime: reminderTime,
                      selectedDays: selectedDays,
                      isEditing: true,
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.grey,
                child: ListTile(
                  title: Text('$medicationDetails',style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dosage: $dosage'),
                      Text('Time: $reminderTime'),
                      Text('Days: $selectedDays'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: notificationToggle,
                        onChanged: (value) async {
                          String medicationDetails = reminders[index]['medicationDetails'];
                          String dosage = reminders[index]['dosage'];
                          List<dynamic> dayOfWeekList = reminders[index]['dayOfWeek'];

                          if (value) {
                            // Call method to restart notifications
                            await restartNotifications(medicationDetails, dosage, dayOfWeekList);
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(_user!.uid)
                                .collection('reminders')
                                .doc(reminders[index].id)
                                .update({'notificationToggle': true});
                          } else {
                            // Call method to cancel notifications
                            await cancelNotifications(medicationDetails, dosage, dayOfWeekList);
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(_user!.uid)
                                .collection('reminders')
                                .doc(reminders[index].id)
                                .update({'notificationToggle': false});
                          }

                          // Update toggle state
                          setState(() {
                            _notificationToggles[index.toString()] = value;
                          });
                        },
                        activeColor: Colors.blueAccent, // Set color when switch is ON
                        inactiveTrackColor: Colors.grey, // Set color of the track when switch is OFF
                      ),
                    ],
                  ),

                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getSelectedDays(List<dynamic> dayOfWeekList) {
    String selectedDays = '';
    for (var day in dayOfWeekList) {
      if (day != null && day.isNotEmpty) {
        switch (day) {
          case 'Monday':
            selectedDays += 'Mon, ';
            break;
          case 'Tuesday':
            selectedDays += 'Tue, ';
            break;
          case 'Wednesday':
            selectedDays += 'Wed, ';
            break;
          case 'Thursday':
            selectedDays += 'Thu, ';
            break;
          case 'Friday':
            selectedDays += 'Fri, ';
            break;
          case 'Saturday':
            selectedDays += 'Sat, ';
            break;
          case 'Sunday':
            selectedDays += 'Sun, ';
            break;
        }
      }
    }
    return selectedDays.isNotEmpty ? selectedDays.substring(0, selectedDays.length - 2) : '';
  }
}
