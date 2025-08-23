import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myproject/HealthRecord/UploadHealthRecordPage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart'; // Import the UploadHealthRecordPage

class HealthRecordListPage extends StatefulWidget {
  @override
  _HealthRecordListPageState createState() => _HealthRecordListPageState();
}

class _HealthRecordListPageState extends State<HealthRecordListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late User _user;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }
  Future<void> _downloadFile(String downloadUrl, String fileName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $fileName...'),
      ),
    );
    try {
      var fileData = await _storage.refFromURL(downloadUrl).getData();
      if (fileData != null) {
        Directory? directory = await getExternalStorageDirectory();
        String downloadsPath = '${directory!.path}/Download';
        Directory downloadsDirectory = Directory(downloadsPath);
        if (!(await downloadsDirectory.exists())) {
          await downloadsDirectory.create(recursive: true);
        }
        String filePath = '$downloadsPath/$fileName';
        File file = File(filePath);
        await file.writeAsBytes(fileData.toList()); // Convert Uint8List to List<int>
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName downloaded successfully!'),
          ),
        );
        await OpenFile.open(filePath); // Open the downloaded file
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download $fileName.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
        ),
      );
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      await _db.collection('user_records').doc(recordId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record deleted successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete record: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Records', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              padding: EdgeInsets.symmetric(vertical: 15.0),
              decoration: BoxDecoration(
                color: Colors.grey, // Changed button background color to grey
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextButton.icon( // Changed to TextButton.icon to add icon before text
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadHealthRecordPage()),
                  );
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black), // Text color
                ),
                icon: Icon(Icons.file_upload, color: Colors.black), // Added file icon
                label: Text(
                  'Upload a new Health Record',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('user_records')
                    .where('userId', isEqualTo: _user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var record = snapshot.data!.docs[index];
                        return Card(
                          elevation: 4, // Add shadow
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(

                            title: Text(
                              record['fileName'],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    // Delete record from Firebase
                                    _deleteRecord(record.id);
                                  },
                                  color: Colors.red, // Set delete button color to red
                                ),
                                IconButton(
                                  icon: Icon(Icons.download),
                                  onPressed: () {
                                    // Download the file
                                    _downloadFile(record['downloadUrl'], record['fileName']);
                                  },
                                  color: Colors.green, // Set download button color to green
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );


                  } else {
                    return Text('No records found.', style: TextStyle(color: Colors.white));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
