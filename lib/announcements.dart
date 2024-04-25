import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turfit/screen/signout.dart';
import 'package:turfit/utils/games_slider.dart';

import '../utils/tournament_slider.dart';

class CreateAnnouncementPage extends StatefulWidget {
  @override
  _CreateAnnouncementPageState createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  TextEditingController _announcementController = TextEditingController();

  void _createAnnouncement() async {
    String announcementText = _announcementController.text;

    if (announcementText.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('announcements').add({
          'text': announcementText,
          'timestamp': DateTime.now(),
        });

        // Clear the text field after storing the announcement
        _announcementController.clear();

        // Show a success message or navigate to a different page
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Announcement created successfully.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Show an error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to create announcement.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.door_back_door),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => SignOut()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _announcementController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Announcement',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    child: Text('Send'),
                    onPressed: _createAnnouncement,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                child: GamesSlider(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                child: TournamentSlider(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
