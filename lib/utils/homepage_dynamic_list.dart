// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turfit/screen/pick_game.dart';
import 'package:turfit/screen/details_screen.dart';
import 'package:turfit/utils/dynamic_icon.dart';
import 'package:turfit/utils/loading_screen.dart';

import '../auth/user_provider.dart';

class ColorPair {
  Color color1;
  Color color2;

  ColorPair({required this.color1, required this.color2});
}

class HomePageDynamicList extends StatefulWidget {
  HomePageDynamicList({Key? key}) : super(key: key);

  @override
  State<HomePageDynamicList> createState() => _HomePageDynamicListState();
}

class _HomePageDynamicListState extends State<HomePageDynamicList> {
  late Stream<List<String>> docIDsStream;

  int totalPlayerCount = 0;
  int totalPlayerCountA = 0;
  int totalPlayerCountB = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> getDocIDsStream() {
    return _firestore.collection('matches').snapshots().map(
        (snapshot) => snapshot.docs.map((document) => document.id).toList());
  }

  Stream<Map<String, int>> getTotalPlayerCountStream(final String matchid) {
    return _firestore
        .collection('matches')
        .doc(matchid)
        .collection('players')
        .snapshots()
        .map((snapshot) {
      int playersA = 0;
      int playersB = 0;
      snapshot.docs.forEach((doc) {
        if (doc.id == 'A') {
          playersA = doc['players'].length;
        } else if (doc.id == 'B') {
          playersB = doc['players'].length;
        }
      });
      return {'A': playersA, 'B': playersB};
    });
  }

  @override
  void initState() {
    super.initState();
    docIDsStream = getDocIDsStream();
  }

  final List<ColorPair> colorPairs = [
    ColorPair(color1: Color(0xFFa091fb), color2: Color(0xFFc895fa)),
    ColorPair(color1: Color(0xFF40aa84), color2: Color(0xFF8ac481)),
    ColorPair(color1: Color(0xFFf48a80), color2: Color(0xFFf9ab77)),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;

    final size = MediaQuery.of(context).size.width * 0.04;

    return StreamBuilder<List<String>>(
      stream: docIDsStream,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return LoadingScreen();
              },
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No data available'),
          );
        }
        return SizedBox(
          height: 200,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              final random = Random();
              final colorPair = colorPairs[random.nextInt(colorPairs.length)];

              final gradient = LinearGradient(
                colors: [colorPair.color1, colorPair.color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              //
              CollectionReference matches = _firestore.collection('matches');

              return StreamBuilder<DocumentSnapshot>(
                stream: matches.doc(snapshot.data![index]).snapshots(),
                builder: (((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> snap =
                          snapshot.data!.data() as Map<String, dynamic>;
                      print("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzsnap");
                      print(snap);
                      print("snapzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz");
                      if (userModel!.college == snap['college']) {
                        return StreamBuilder<Map<String, int>>(
                          stream: getTotalPlayerCountStream(snap['matchID']),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map<String, int> totalPlayerCounts =
                                  snapshot.data!;

                              int playerCountA = totalPlayerCounts['A']!;
                              int playerCountB = totalPlayerCounts['B']!;
                              int totalPlayerCount =
                                  playerCountA + playerCountB;
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
                                child: Container(
                                  width: 170,
                                  margin: EdgeInsets.only(left: 20),
                                  decoration: BoxDecoration(
                                    gradient: gradient,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Chip(
                                              backgroundColor: colorPair.color1
                                                  .withOpacity(0.8),
                                              label: Text(snap['name']),
                                            ),
                                            Row(
                                              children: [
                                                Text(snap['seatsLeft']
                                                    .toString()),
                                                Container(
                                                  width: 15,
                                                  height: 15,
                                                  margin: EdgeInsets.all(3),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        snap['seatsLeft'] == 0
                                                            ? Colors.red
                                                            : Colors
                                                                .greenAccent,
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
                                              documentReference:
                                                  FirebaseFirestore.instance
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
                                              documentReference:
                                                  FirebaseFirestore.instance
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
                                                  style:
                                                      TextStyle(fontSize: size),
                                                ),
                                                Text(
                                                  'Team B',
                                                  style:
                                                      TextStyle(fontSize: size),
                                                ),
                                              ]),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    '$playerCountA',
                                                    style: TextStyle(
                                                        fontSize: size),
                                                  ),
                                                  Text(
                                                    '$playerCountB',
                                                    style: TextStyle(
                                                        fontSize: size),
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
                      } else {
                        return Container();
                      }
                    }
                  }
                  return LoadingScreen();
                })),
              );
            },
          ),
        );
      }),
    );
  }
}
