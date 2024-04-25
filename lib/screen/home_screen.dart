// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:turfit/auth/auth_methods.dart';
import 'package:turfit/auth/user_provider.dart';
import 'package:turfit/screen/announcements.dart';
import 'package:turfit/screen/login_screen.dart';
import 'package:turfit/screen/notifications.dart';
import 'package:turfit/screen/pick_game.dart';
import 'package:turfit/utils/carousel_slider.dart';
import 'package:turfit/utils/games_slider.dart';
import 'package:turfit/utils/tournament_slider.dart';

import 'view_announcements.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi ${userModel!.mail}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              'welcome back',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            )
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AnnouncementsPage(),
                ),
              );
            },
            child: SizedBox(
                height: 25, width: 25, child: Icon(CupertinoIcons.bell)
                // SvgPicture.network(
                //   'https://avatars.dicebear.com/api/identicon/${userModel.mail}.svg',
                // ),
                ),
          ),
          SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 10,
          ),
        ],
        leading: IconButton(
            onPressed: () => ZoomDrawer.of(context)!.toggle(),
            icon: Icon(Icons.menu)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              child: MySlider(),
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
            // Center(child: Text(userModel.mail)),
            // ElevatedButton(
            //     onPressed: () async {
            //       await authmethods().signOut();
            //       Navigator.of(context).pushReplacement(
            //           MaterialPageRoute(builder: (_) => loginscreen()));
            //     },
            //     child: Text('logout'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green[300],
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OnboardingScreen(
                GoT: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
