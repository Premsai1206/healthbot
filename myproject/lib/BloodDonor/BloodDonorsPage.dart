import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'DonationForm.dart';

class BloodDonorsPage extends StatefulWidget {
  @override
  _BloodDonorsPageState createState() => _BloodDonorsPageState();
}

class _BloodDonorsPageState extends State<BloodDonorsPage> {
  String? selectedBloodGroup;
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set app bar background color to black
        title: Text(
          'Blood Donors',
          style: TextStyle(color: Colors.white), // Set app bar title text color to white
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back button color to white
      ),
      body: Container(
        color: Colors.black, // Change background color to black
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DonationForm()),
                    );
                  },
                  child: Text(
                    'Become A Donor',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Blood Group',style: TextStyle(color: Colors.grey),),
                    value: selectedBloodGroup,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBloodGroup = newValue;
                      });
                    },
                    style: TextStyle(color: Colors.white), // Dropdown text color
                    dropdownColor: Colors.black, // Dropdown background color
                    items: <String>['A+', 'B+', 'AB+', 'O+', 'A-', 'B-', 'AB-', 'O-'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white), // Dropdown item text color
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    hint: Text('Select City',style: TextStyle(color: Colors.grey),),
                    value: selectedCity,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCity = newValue;
                      });
                    },
                    style: TextStyle(color: Colors.white), // Dropdown text color
                    dropdownColor: Colors.black, // Dropdown background color
                    items: <String>['Hyderabad', 'Delhi', 'Mumbai', 'Bangalore', 'Chennai'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white), // Dropdown item text color
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('donors').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    bool bloodGroupFilter = selectedBloodGroup == null || selectedBloodGroup == doc['bloodGroup'];
                    bool cityFilter = selectedCity == null || selectedCity == doc['city'];
                    return bloodGroupFilter && cityFilter;
                  }).toList();
                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var document = filteredDocs[index];
                      return Card(
                        elevation: 4,
                        color: Colors.grey,// Add shadow to the card
                        child: ListTile(
                          title: Text(document['name']),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSubtitleField("Gender", document['gender']),
                              _buildSubtitleField("City", document['city']),
                              _buildSubtitleField("Location", document['location']),
                              _buildSubtitleField("Blood Group", document['bloodGroup']),
                              _buildSubtitleField("Phone Number", document['phoneNumber']),
                            ],

                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () {
                              _makePhoneCall(document['phoneNumber']);
                            },
                          ), // Add more details or customize the ListTile as needed
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    if (await canLaunchUrlString('tel:$phoneNumber')) {
      await launchUrlString('tel:$phoneNumber');
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Widget _buildSubtitleField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
