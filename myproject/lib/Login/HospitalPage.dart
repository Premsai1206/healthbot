import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HospitalPage extends StatefulWidget {
  late String speciality;

  HospitalPage(this.speciality);

  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  String? selectedLocation; // Change the type to String?
  List<String> locations = ['All', 'Kukatpally', 'Banjara Hills', 'Secunderabad', 'Gandipet']; // Define your locations here

  @override
  void initState() {
    super.initState();
    selectedLocation = null; // Initially no location selected
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.speciality} Hospitals',
          style: TextStyle(color: Colors.white), // Set text color of app bar title
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back button color
        backgroundColor: Colors.black, // Set background color of app bar
      ),
      backgroundColor: Colors.black, // Set background color of the entire screen
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: Text(
                'Select a location',
                style: TextStyle(color: Colors.white), // Set text color of hint
              ),
              value: selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLocation = newValue;
                });
              },
              items: locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.white), // Set text color of dropdown items
                  ),
                );
              }).toList(),
              dropdownColor: Colors.black, // Set dropdown background color
              icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Set dropdown icon color
              elevation: 4, // Set elevation of dropdown
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white), // Set text color
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No data found',
                      style: TextStyle(color: Colors.white), // Set text color
                    ),
                  );
                }
                if (widget.speciality == 'General') {
                  widget.speciality = 'General Physician';
                }
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic> or null
                  // Check if data is not null and if it contains the 'SPECIALITY' key
                  return data != null &&
                      data.containsKey('SPECIALITY') &&
                      data['SPECIALITY'] == widget.speciality &&
                      (selectedLocation == null || selectedLocation == 'All' || (data.containsKey('LOCATION') && data['LOCATION'] == selectedLocation));
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'No hospitals found for speciality: ${widget.speciality} and location: ${selectedLocation ?? "All"}',
                      style: TextStyle(color: Colors.white), // Set text color
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final document = filteredDocs[index];
                    return Card(
                      elevation: 4,
                      color: Colors.grey, // Set card background color
                      child: ListTile(
                        title: Text(
                          document['NAME'],
                          style: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 19), // Set text color
                        ), // Adjust field names if necessary
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSubtitleField("Speciality", document['SPECIALITY']),
                            _buildSubtitleField("Location", document['LOCATION']),
                            _buildSubtitleField("Address", document['ADDRESS']),
                            _buildSubtitleField("Phone Number", document['PHONE NUMBER']),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.phone, color: Colors.black), // Set icon color
                          onPressed: () {
                            _makePhoneCall(document['PHONE NUMBER']);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Set text color
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black), // Set text color
            ),
          ),
        ],
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
}
