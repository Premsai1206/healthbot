import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:myproject/components/icons.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationPage extends StatefulWidget {
  static int _notificationIdCounter = 0;
  final bool notificationToggle;
  final String? medication;
  final String? dosage;
  final DateTime? reminderTime;
  final Map<String, bool>? selectedDays;
  final bool isEditing;
  static final User? user = FirebaseAuth.instance.currentUser;

  const NotificationPage({
    Key? key,
    this.medication,
    this.dosage,
    this.reminderTime,
    this.selectedDays,
    this.isEditing = false,
    this.notificationToggle = true,
  }) : super(key: key);

  static int _getDayOfWeek(String day) {
    switch (day) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
    required DateTime? scheduleTime,
    required String medicine,
    required String dosage,
    required Map<String, bool> selectedDays,
  }) async {
    tz.initializeTimeZones();
    List<String> selectedDaysList = [];

    selectedDays.forEach((day, isSelected) {
      if (isSelected) {
        selectedDaysList.add(day);
      }
    });

    int notificationId = ++NotificationPage._notificationIdCounter;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('reminders').add({
      'notificationId': notificationId,
      'medicationDetails': medicine,
      'dosage': dosage,
      'reminderTime': scheduleTime,
      'dayOfWeek': selectedDaysList,
      'notificationToggle': true,
    });

    await Future.forEach(selectedDaysList, (selectedDay) async {
      var dayOfWeek = _getDayOfWeek(selectedDay);
      var scheduledTime = scheduleTime!;
      while (scheduledTime.weekday != dayOfWeek) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'channel 3',
            'schedule_channel',
            channelDescription: 'schedule notifications',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
        payload: payload,
      );
    });
  }

  @override
  State<NotificationPage> createState() => _NotificationState();
}

class _NotificationState extends State<NotificationPage> {
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  static final User? user = FirebaseAuth.instance.currentUser;
  DateTime? _selectedTime;
  Map<String, bool> _selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    if (widget.isEditing) {
      _medicationController.text = widget.medication ?? '';
      _dosageController.text = widget.dosage ?? '';
      _selectedTime = widget.reminderTime;
      widget.selectedDays?.forEach((day, isSelected) {
        _selectedDays[day] = isSelected;
      });
    }
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> cancelExistingNotifications() async {
    if (widget.isEditing) {
      List<String> selectedDaysList = [];
      widget.selectedDays?.forEach((day, isSelected) {
        if (isSelected) {
          selectedDaysList.add(day);
        }
      });
      // Cancel the associated notifications
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('reminders')
          .where('medicationDetails', isEqualTo: widget.medication)
          .where('dosage', isEqualTo: widget.dosage)
          .where('dayOfWeek', isEqualTo: selectedDaysList)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          var reminderId = doc['notificationId'];
          await flutterLocalNotificationsPlugin.cancel(reminderId);
        });
      });
      // Delete the document from Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('reminders')
          .where('medicationDetails', isEqualTo: widget.medication)
          .where('dosage', isEqualTo: widget.dosage)
          .where('dayOfWeek', isEqualTo: selectedDaysList)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
      });
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isEditing) {
      _medicationController.text = widget.medication ?? '';
      _dosageController.text = widget.dosage ?? '';
      _selectedTime = widget.reminderTime;
      widget.selectedDays?.forEach((day, isSelected) {
        _selectedDays[day] = isSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedTimeString = _selectedTime != null
        ? DateFormat('hh:mm a').format(_selectedTime!)
        : 'Select Time';

    return Scaffold(
      appBar: AppBar(
        title: widget.isEditing? const Text('Add a Reminder', style: TextStyle(color: Colors.white)) : Text('Update Reminder', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: widget.isEditing
            ? [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              await cancelExistingNotifications();
              setState(() {
                // Clear medication, dosage, time, and selected days
                _medicationController.clear();
                _dosageController.clear();
                _selectedTime = null;
                _selectedDays.forEach((key, value) {
                  _selectedDays[key] = false;
                });
              });
              Navigator.pop(context);
            },
          ),
        ]
            : null,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(AppAssets.icPill, height: 200, width: 200),
              SizedBox(height: 20),
              TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(
                  labelText: 'Medication',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Time:',style: TextStyle(color: Colors.white),),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime != null
                            ? TimeOfDay(hour: _selectedTime!.hour, minute: _selectedTime!.minute)
                            : TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedTime = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                    child: Text(selectedTimeString, style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(primary: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text('Select days for reminder:', style: TextStyle(color: Colors.white)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Align the children horizontally
                children: [
                  Wrap(
                    spacing: 18,
                    children: _selectedDays.keys.map((day) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDays[day] = !_selectedDays[day]!;
                          });
                        },
                        child: Container(
                          width: 30, // Set a fixed width for the container
                          height: 30, // Set a fixed height for the container
                          padding: EdgeInsets.all(5), // Adjust padding for smaller circles
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedDays[day]! ? Colors.red : Colors.grey[900],
                          ),
                          child: Center(
                            child: Text(
                              day.substring(0, 1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Adjust font size for smaller circles
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (widget.isEditing) {
                    await cancelExistingNotifications();
                  }

                  if (_medicationController.text.isNotEmpty &&
                      _dosageController.text.isNotEmpty &&
                      _selectedTime != null) {
                    await NotificationPage.showScheduleNotification(
                      title: 'Medication Reminder',
                      body: 'Time to take ${_dosageController.text} of ${_medicationController.text}',
                      payload: '',
                      scheduleTime: _selectedTime,
                      medicine: _medicationController.text,
                      dosage: _dosageController.text,
                      selectedDays: _selectedDays,
                    );
                    setState(() {
                      _medicationController.clear();
                      _dosageController.clear();
                      _selectedTime = null;
                      _selectedDays.forEach((key, value) {
                        _selectedDays[key] = false;
                      });
                    });

                    Navigator.pop(context);
                  } else {
                    // Handle if medication, dosage, or time is not selected
                  }
                },
                child: const Text('Schedule Reminder', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
