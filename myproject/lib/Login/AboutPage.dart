import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/Notifications/ReminderPage.dart';

import '../BMI/BMIPage.dart';
import '../HealthRecord/HealthRecordListPage.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  signout() async{
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Colors.black,
       title: Text('About',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 50,
              child: Icon(
                Icons.person,
                color: Colors.black,
                size: 90,
              ),
            ),
            SizedBox(height: 20,),
            Container(
              alignment: Alignment.center,
              child: Text(
                '${user?.email ?? "Guest"}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BMIPage()),
                );
              },

              title: Text('Calculate your BMI',style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 10),

            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HealthRecordListPage()),
                );
              },

              title: Text('Your medical records',style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReminderPage()),
                );
              },

              title: Text('Your reminders',style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => signout(),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.logout, color: Colors.white,size: 30,),
                    SizedBox(width: 10),
                    Text('Sign Out', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
