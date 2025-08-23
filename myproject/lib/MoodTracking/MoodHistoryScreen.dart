import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mood History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: FutureBuilder(
          future: getMoodHistory(),
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white),
              );
            } else {
              final moodDocs = snapshot.data!;
              return ListView.builder(
                itemCount: moodDocs.length,
                itemBuilder: (context, index) {
                  final mood = moodDocs[index];
                  final timestamp = mood['timestamp'] as Timestamp;
                  final formattedDateTime = DateFormat.yMd().add_jm().format(timestamp.toDate());
                  return Card(
                    color: Colors.grey,
                    child: ListTile(
                      title: Text(mood['mood'], style: TextStyle(color: Colors.black)),
                      subtitle: Text('Recorded on: $formattedDateTime', style: TextStyle(color: Colors.black)),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> getMoodHistory() async {
    final user = FirebaseAuth.instance.currentUser!;
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs;
  }
}
