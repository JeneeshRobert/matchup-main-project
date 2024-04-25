// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:turfit/screen/details_screen.dart';
import 'package:turfit/screen/tournament_details_screen.dart';
import 'package:turfit/utils/dynamic_icon.dart';
import 'package:turfit/utils/homepage_dynamic_list.dart';

class CMatches extends StatefulWidget {
  final bool hslashp;

  CMatches({this.hslashp = true});

  @override
  _CMatchesState createState() => _CMatchesState();
}

class _CMatchesState extends State<CMatches> {
  List<String> _conductedTournaments = [];
  int totalPlayerCount = 0;
  int totalPlayerCountA = 0;
  int totalPlayerCountB = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, int>> getTotalPlayerCount(final String matchid) async {
    int playersA = 0;
    int playersB = 0;

    try {
      // Get the 'A' and 'B' player documents
      DocumentSnapshot playerADoc = await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchid)
          .collection('players')
          .doc('A')
          .get();

      DocumentSnapshot playerBDoc = await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchid)
          .collection('players')
          .doc('B')
          .get();

      // Get the 'players' arrays from the 'A' and 'B' player documents
      playersA =
          (playerADoc.data() as Map<String, dynamic>?)?['players']?.length ?? 0;
      playersB =
          (playerBDoc.data() as Map<String, dynamic>?)?['players']?.length ?? 0;

      // Calculate the total length of the 'players' arrays
      // Return player counts as a map
    } catch (e) {
      print('Error fetching player count: $e');
    }
    return {'A': playersA, 'B': playersB};
  }

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
        _conductedTournaments =
            List<String>.from(userSnapshot.get('conductedMatches') ?? []);
      });
    }
  }

  final List<ColorPair> colorPairs = [
    ColorPair(color1: Color(0xFFa091fb), color2: Color(0xFFc895fa)),
    ColorPair(color1: Color(0xFF40aa84), color2: Color(0xFF8ac481)),
    ColorPair(color1: Color(0xFFf48a80), color2: Color(0xFFf9ab77)),
  ];
  Widget _buildTournamentsGrid() {
    final size = MediaQuery.of(context).size.width * 0.04;

    if (_conductedTournaments.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => ZoomDrawer.of(context)!.toggle(),
              icon: Icon(Icons.menu),
            ),
          ),
          body: Center(child: Text('No matches found')));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Conducted Matches'),
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
            itemBuilder: (ctx, index) {
              final random = Random();
              final colorPair = colorPairs[random.nextInt(colorPairs.length)];

              final gradient = LinearGradient(
                colors: [colorPair.color1, colorPair.color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              //
              CollectionReference matches = _firestore.collection('matches');

              return FutureBuilder<DocumentSnapshot>(
                future: matches.doc(_conductedTournaments[index]).get(),
                builder: (((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> snap =
                        snapshot.data!.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, int>>(
                      future: getTotalPlayerCount(snap['matchID']),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map<String, int> totalPlayerCounts = snapshot.data!;

                          int playerCountA = totalPlayerCounts['A']!;
                          int playerCountB = totalPlayerCounts['B']!;
                          int totalPlayerCount = playerCountA + playerCountB;
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DetailsPage(
                                    snap: snap,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete Confirmation'),
                                    content: Text(
                                        'Are you sure you want to delete?'),
                                    actions: [
                                      TextButton(
                                        child: Text('No'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Yes'),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('please wait'),
                                                content: Text(
                                                    'Making in progress..'),
                                              );
                                            },
                                          );
                                          CollectionReference
                                              playersCollection =
                                              FirebaseFirestore.instance
                                                  .collection('matches')
                                                  .doc(snap['matchID'])
                                                  .collection('players');

                                          QuerySnapshot querySnapshot =
                                              await playersCollection.get();
                                          CollectionReference usersCollection =
                                              FirebaseFirestore.instance
                                                  .collection('users');

                                          for (QueryDocumentSnapshot documentSnapshot
                                              in querySnapshot.docs) {
                                            final data = documentSnapshot.data()
                                                as Map<String, dynamic>;
                                            List<dynamic> list =
                                                data['players'];
                                            for (var map in list) {
                                              String userID = map['userID'];
                                              DocumentReference userDocument =
                                                  usersCollection.doc(userID);

                                              await userDocument.update({
                                                'participatedMatches':
                                                    FieldValue.arrayRemove(
                                                        [snap['matchID']]),
                                              });
                                            }
                                          }
                                          DocumentReference userDocument =
                                              usersCollection.doc(FirebaseAuth
                                                  .instance.currentUser!.uid);

                                          await userDocument.update({
                                            'conductedMatches':
                                                FieldValue.arrayRemove(
                                                    [snap['matchID']]),
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('matches')
                                              .doc(snap['matchID'])
                                              .collection('players')
                                              .doc('A')
                                              .delete();
                                          await FirebaseFirestore.instance
                                              .collection('matches')
                                              .doc(snap['matchID'])
                                              .collection('players')
                                              .doc('B')
                                              .delete();
                                          await FirebaseFirestore.instance
                                              .collection('matches')
                                              .doc(snap['matchID'])
                                              .delete();
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 170,
                              margin: EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Chip(
                                          backgroundColor:
                                              colorPair.color1.withOpacity(0.8),
                                          label: Text(snap['name']),
                                        ),
                                        Row(
                                          children: [
                                            Text(snap['seatsLeft'].toString()),
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
                                                  backgroundColor:
                                                      snap['seatsLeft'] == 0
                                                          ? Colors.red
                                                          : Colors.greenAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        PlayerCountIcon(
                                          iconData: Icons
                                              .sports_soccer, // Replace with your desired icon
                                          documentReference: FirebaseFirestore
                                              .instance
                                              .collection('matches')
                                              .doc(snap['matchID'])
                                              .collection('players')
                                              .doc('A'),
                                          maxSize: 11,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('-'),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        PlayerCountIcon(
                                          iconData: Icons
                                              .sports_soccer, // Replace with your desired icon
                                          documentReference: FirebaseFirestore
                                              .instance
                                              .collection('matches')
                                              .doc(snap['matchID'])
                                              .collection('players')
                                              .doc('B'),
                                          maxSize: 11,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(children: [
                                            Text(
                                              'Team A',
                                              style: TextStyle(fontSize: size),
                                            ),
                                            Text(
                                              'Team B',
                                              style: TextStyle(fontSize: size),
                                            ),
                                          ]),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '$playerCountA',
                                                style:
                                                    TextStyle(fontSize: size),
                                              ),
                                              Text(
                                                '$playerCountB',
                                                style:
                                                    TextStyle(fontSize: size),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    );
                  }
                  return Container();
                })),
              );
            }),
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
