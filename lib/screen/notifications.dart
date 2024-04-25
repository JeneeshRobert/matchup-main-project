// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Future<List<String>> fetchNotifications() async {
    List<String> notifications = [];
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = userSnapshot.data() as Map<String, dynamic>;
    print(data['notifications']);
    for (var x in data['notifications']) {
      notifications.add(x.toString());
    }
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<String>>(
            future: fetchNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child:
                        CircularProgressIndicator()); // Show a loading indicator while waiting for data
              }
              List<String> notifications = snapshot.data!.reversed.toList();
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (BuildContext context, int index) {
                  String notification = notifications[index];
                  return NotificationBox(
                    text: notification,
                  );
                },
              );
            }),
      ),
    );
  }
}

class NotificationBox extends StatelessWidget {
  final String text;
  const NotificationBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/ic_launcher.png'),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              text,
              maxLines: null, // Allow unlimited lines
              overflow: TextOverflow.visible, // Show overflow text
            ),
          ),
        ],
      ),
    );
  }
}
