import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('announcements').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show a loading indicator while waiting for data
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          List<DocumentSnapshot> announcements = snapshot.data!.docs;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot announcement = announcements[index];
              print(announcement.data());
              final data = announcement.data() as Map<String, dynamic>;
              String text = data['text'];
              DateTime timestamp = data['timestamp'].toDate();

              return ListTile(
                title: Text(text),
                subtitle: Text('Posted on: ${timestamp.toString()}'),
              );
            },
          );
        },
      ),
    );
  }
}
