// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:turfit/screen/tournament_details_screen.dart';
import 'package:turfit/utils/homepage_dynamic_list.dart';

class PersonalPTournamentsScreen extends StatefulWidget {
  final bool hslashp;

  PersonalPTournamentsScreen({this.hslashp = true});

  @override
  _PersonalPTournamentsScreenState createState() =>
      _PersonalPTournamentsScreenState();
}

class _PersonalPTournamentsScreenState
    extends State<PersonalPTournamentsScreen> {
  List<String> _conductedTournaments = [];

  @override
  void initState() {
    super.initState();
    _loadConductedTournaments();
  }

  Future<void> _loadConductedTournaments() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (userSnapshot.exists) {
      setState(() {
        _conductedTournaments = List<String>.from(
            userSnapshot.get('participatedTournaments') ?? []);
      });
    }
  }

  final List<ColorPair> colorPairs = [
    ColorPair(color1: Color(0xFFa091fb), color2: Color(0xFFc895fa)),
    ColorPair(color1: Color(0xFF40aa84), color2: Color(0xFF8ac481)),
    ColorPair(color1: Color(0xFFf48a80), color2: Color(0xFFf9ab77)),
  ];
  Widget _buildTournamentsGrid() {
    if (_conductedTournaments.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => ZoomDrawer.of(context)!.toggle(),
              icon: Icon(Icons.menu),
            ),
          ),
          body: Center(child: Text('No tournaments')));
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => ZoomDrawer.of(context)!.toggle(),
            icon: Icon(Icons.menu),
          ),
        ),
        body: GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 3,
          ),
          itemCount: _conductedTournaments.length,
          itemBuilder: (ctx, index) => FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('tournaments')
                .doc(_conductedTournaments[index])
                .get(),
            builder: (ctx, snapshot) {
              final random = Random();
              final colorPair = colorPairs[random.nextInt(colorPairs.length)];

              final gradient = LinearGradient(
                colors: [colorPair.color1, colorPair.color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading tournament'));
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('Tournament not found'));
              } else {
                Map<String, dynamic> tournamentData = snapshot.data!.data()!;
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => TournamentDetailsPage(
                            snap: tournamentData,
                          ))),
                  child: Container(
                    width: 170,
                    margin: EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    backgroundColor:
                                        colorPair.color1.withOpacity(0.8),
                                    label: Text(tournamentData['name']),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    height: 20.0,
                                    width: 20.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      margin: EdgeInsets.all(3),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.greenAccent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.sportscourt,
                                  size: 40,
                                ),
                                tournamentData['maxTeam'] == 0
                                    ? Text(
                                        '♾️',
                                        style: TextStyle(
                                          fontSize: 30,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              "${tournamentData['maxTeam']} Teams left"),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTournamentsGrid(),
    );
  }
}
