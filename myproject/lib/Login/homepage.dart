import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/Login/AboutPage.dart';
import 'package:myproject/BMI/BMIPage.dart';
import 'package:myproject/BloodDonor/BloodDonorsPage.dart';
import 'package:myproject/Chatbot/ChatbotPage.dart';
import 'package:myproject/EmergencyAssistance/EmergencyAssistanceScreen.dart';
import 'package:myproject/HealthRecord/HealthRecordListPage.dart';
import 'package:myproject/MoodTracking/MoodTrackerScreen.dart';

import 'package:myproject/Notifications/ReminderPage.dart';
import 'package:myproject/components/icons.dart';

import 'HospitalPage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final User? user = FirebaseAuth.instance.currentUser;

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  var iconList = [
    AppAssets.icBloodDonation,
    AppAssets.icChatbot,
    AppAssets.icClock
  ];

  var backgroundColorList = [
    Colors.red,
    Colors.green,
    Colors.orange,
  ];

  var titleList = [
    'Find a Donor',
    'Talk to Our MediBot',
    'Medication Reminders',
  ];
  var iconsList = [
    AppAssets.icBody,
    AppAssets.icHeart,
    AppAssets.icKidney,
    AppAssets.icLiver,
    AppAssets.icEye,
    AppAssets.icTooth
  ];

  var iconTitleList = [
    'General',
    'Heart',
    'Kidney',
    'Liver',
    'Eyes',
    'Dental'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/health-insurance.png', // Change to your app logo asset path
              width:50, // Adjust the size as needed
              height: 40,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              "HealthGuard",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutPage()));
            },
            icon: Icon(
              Icons.account_circle,
              size: 45,
            ),
            color: Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black, // Set the background color to black
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Row(
                    children: List.generate(
                      iconList.length,
                          (index) => buildPageCard(
                        title: titleList[index],
                        icon: Image.asset(iconList[index],
                        color: Colors.black,
                        height: 125,
                        width: 125,),
                        backgroundColor: backgroundColorList[index],
                        onPressed: () {
                          switch (index) {
                            case 0:
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BloodDonorsPage()),
                              );
                              break;
                            case 1:
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatbotPage()),
                              );
                              break;
                            case 2:
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReminderPage()),
                              );
                              break;
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: EdgeInsets.all(11.0),
                    child: Row(
                      children: [

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Find your Hospital',
                            style: TextStyle(color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: iconsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                // Navigate to hospital page with corresponding icon string
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HospitalPage(iconTitleList[index]),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(right: 8),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      iconsList[index],
                                      width: 50,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      iconTitleList[index],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Container(
                    child: Column(
                      children: [
                        // Additional content
                        // First row
                        Padding(
                          padding: EdgeInsets.all(11.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 0.4,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BMIPage()));
                          },
                          title: Row(
                            children: [
                              Image.asset(
                                AppAssets.icBMI, // Your feature 1 icon asset path
                                width: 80,
                                height: 80,
                              ),
                              SizedBox(width: 20),
                              Text(
                                'Calculate your BMI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 8,),
                        // Second feature
                        ListTile(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>HealthRecordListPage()));
                          },
                          title: Row(
                            children: [
                              Image.asset(
                                AppAssets.icHealthRecord, // Your feature 2 icon asset path
                                width: 70,
                                height: 70,
                                color: Colors.white,
                              ),
                              SizedBox(width: 20),
                              Text(
                                'Add your medical records',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        // Second row
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Third feature
                              ListTile(
                                onTap: () {
                                  // Implement feature 3 functionality
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EmergencyAssistanceScreen()));
                                },
                                title: Row(
                                  children: [
                                    Image.asset(
                                      AppAssets.icAmbulance, // Your feature 3 icon asset path
                                      width: 70,
                                      height: 70,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'Emergency Assistance',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 20,),
                              ListTile(
                                onTap: () {
                                  // Implement feature 3 functionality
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MoodTrackerScreen()));
                                },
                                title: Row(
                                  children: [
                                    Image.asset(
                                      AppAssets.icMood, // Your feature 3 icon asset path
                                      width: 70,
                                      height: 70,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'Track your mood.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ), ),

            ],
          ),
        ),
      ),

    );
  }

  Widget buildPageCard({
    required String title,
    required Image icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: backgroundColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 340,
          height: 180,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              Text(
                title,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                fontSize: 17,fontStyle: FontStyle.italic),
              ),
              SizedBox(width: 10),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}
