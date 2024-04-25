// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turfit/auth/user_provider.dart';
import 'package:turfit/screen/add_team_tournament.dart';
import 'package:turfit/temp.dart';

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
  Map<String, dynamic> toJson() => {
        'userID': id,
        'name': name,
      };
}

class TournamentDetailsPage extends StatefulWidget {
  var snap;
  bool fromAdmin;
  TournamentDetailsPage(
      {super.key, required this.snap, this.fromAdmin = false});

  @override
  State<TournamentDetailsPage> createState() => Tournament_DetailsPageState();
}

class Tournament_DetailsPageState extends State<TournamentDetailsPage> {
  List<User> usersA = [];
  List<User> usersB = [];

  List<String> namesA = [];
  late ConfettiController confettiController;
  List<String> namesB = [];
  bool _isconfetti = false;

  @override
  void initState() {
    super.initState();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  Future<bool> isMatchIdInUserMatches(String matchId) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final userMatches = await userDoc.get().then((doc) {
      return doc.data()?['participatedTournaments'];
    });

    return userMatches != null && userMatches.contains(matchId);
  }

  void addMatchData(
      {required String matchID,
      required String team,
      required String name}) async {
    final User user =
        User(id: FirebaseAuth.instance.currentUser!.uid, name: name);

    try {
      await FirebaseFirestore.instance
          .collection("matches")
          .doc(matchID)
          .collection('players')
          .doc(team)
          .update(
        {
          "players": FieldValue.arrayUnion(
            [user.toJson()],
          ),
        },
      );
    } catch (e) {
      e.toString();
    }
  }

  late var data;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;
    final fontSize = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          body: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('tournaments')
                  .doc(widget.snap['tournamentId'])
                  .collection('players')
                  .get(),
              builder: (context, snapshotQ) {
                if (snapshotQ.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                QuerySnapshot tournamentSnapshot = snapshotQ.data!;
                int tournamentCount = tournamentSnapshot.size;
                print("tournamentCount");
                print(tournamentCount);
                print(widget.snap['open']);
                if (tournamentCount == 1 && !widget.snap['open']) {
                  confettiController.play();
                  print("yeah");
                }
                return FutureBuilder<bool>(
                    future: isMatchIdInUserMatches(widget.snap['tournamentId']),
                    builder: (context, snapshotData) {
                      if (snapshotData.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshotData.hasError) {
                        return Text('Error: ${snapshotData.error}');
                      }
                      print(snapshotData.data);
                      return StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('tournaments')
                              .doc(widget.snap['tournamentId'])
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            final data = snapshot.data!.data();
                            return SafeArea(
                              child: Stack(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF009bdd),
                                          Color(0xFF02dac1)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF181920),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(60),
                                          topRight: Radius.circular(60),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: fontSize * 0.06,
                                          right: fontSize * 0.06,
                                          top: fontSize * 0.35,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Description',
                                                    style: TextStyle(
                                                      fontSize:
                                                          fontSize * 0.035,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: fontSize * 0.03,
                                                  ),
                                                  Text(
                                                    widget.snap['description'],
                                                    style: TextStyle(
                                                      fontSize: fontSize * 0.03,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: fontSize * 0.08,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Location',
                                                    style: TextStyle(
                                                      fontSize:
                                                          fontSize * 0.035,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: fontSize * 0.03,
                                                  ),
                                                  Text(
                                                    widget.snap['location'],
                                                    style: TextStyle(
                                                      fontSize: fontSize * 0.03,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: fontSize * 0.02,
                                                  ),
                                                  // Text(
                                                  //   "Get location ",
                                                  //   style: TextStyle(
                                                  //     fontSize: fontSize * 0.03,
                                                  //     color: Colors.red[300],
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 600,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: StreamBuilder<
                                                          QuerySnapshot>(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'tournaments')
                                                            .doc(widget.snap[
                                                                'tournamentId'])
                                                            .collection(
                                                                'players')
                                                            .snapshots(),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    QuerySnapshot>
                                                                snapshot) {
                                                          if (snapshot
                                                              .hasError) {
                                                            return Text(
                                                                'Error: ${snapshot.error}');
                                                          }
                                                          switch (snapshot
                                                              .connectionState) {
                                                            case ConnectionState
                                                                .waiting:
                                                              return Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                                child: Text(
                                                                  'Loading...',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              );
                                                            default:
                                                              final players =
                                                                  snapshot.data!
                                                                      .docs;
                                                              print("players");
                                                              print(players);
                                                              if (players
                                                                      .length ==
                                                                  0) {
                                                                return Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child: Text(
                                                                    'No players',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                              return ListView
                                                                  .builder(
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    players
                                                                        .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  if (players[index]
                                                                          [
                                                                          "teamId"] !=
                                                                      'temp') {
                                                                    final playerData = players[index]
                                                                            [
                                                                            'players']
                                                                        as List<
                                                                            dynamic>;
                                                                    final playerMaps =
                                                                        playerData;

                                                                    return Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                        child:
                                                                            Table(
                                                                          defaultVerticalAlignment:
                                                                              TableCellVerticalAlignment.middle,
                                                                          children: [
                                                                            // Table header row
                                                                            TableRow(
                                                                              children: [
                                                                                Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.grey[300],
                                                                                  ),
                                                                                  padding: EdgeInsets.all(8.0),
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      '${players[index]["teamName"]} (${playerMaps.length})',
                                                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),

                                                                            // Table data rows
                                                                            ...playerMaps.map(
                                                                              (name) => TableRow(
                                                                                children: [
                                                                                  Container(
                                                                                    decoration: BoxDecoration(color: Colors.grey[100]),
                                                                                    padding: EdgeInsets.all(8.0),
                                                                                    child: Center(
                                                                                      child: Text(name['name'].toString()),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                              );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    // SizedBox(
                                                    //   height: fontSize * 0.06,
                                                    // ),
                                                    SizedBox(
                                                      height: fontSize * 0.06,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.05,
                                    top: MediaQuery.of(context).size.height *
                                        0.25,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2b2e3b),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              data!['name'],
                                              style: TextStyle(
                                                fontSize: fontSize * 0.042,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                            SizedBox(
                                              height: fontSize * 0.03,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    FaIcon(
                                                      FontAwesomeIcons
                                                          .calendarDays,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      size: fontSize * 0.05,
                                                    ),
                                                    SizedBox(
                                                      height: fontSize * 0.02,
                                                    ),
                                                    Text(
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(
                                                        data['tournamentDateTime']
                                                            .toDate(),
                                                      ),
                                                      style: TextStyle(
                                                        fontSize:
                                                            fontSize * 0.025,
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    FaIcon(
                                                      FontAwesomeIcons
                                                          .peopleLine,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      size: fontSize * 0.05,
                                                    ),
                                                    SizedBox(
                                                      height: fontSize * 0.02,
                                                    ),
                                                    Text(
                                                      '${data["seats"]} / Team',
                                                      style: TextStyle(
                                                        fontSize:
                                                            fontSize * 0.025,
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    FaIcon(
                                                      FontAwesomeIcons
                                                          .moneyBill1Wave,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      size: fontSize * 0.05,
                                                    ),
                                                    SizedBox(
                                                      height: fontSize * 0.02,
                                                    ),
                                                    Text(
                                                      data["price"].toString(),
                                                      style: TextStyle(
                                                        fontSize:
                                                            fontSize * 0.025,
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.46,
                                    top: MediaQuery.of(context).size.height *
                                        0.16,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2b2e3b),
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.basketball,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 10,
                                    top: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            CupertinoIcons.back,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                        ),
                                        color: Color(0xFF2b2e3b),
                                      ),
                                      child: snapshotData.data == false
                                          ? Row(
                                              children: [
                                                Expanded(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (widget.fromAdmin) {
                                                        print(!widget
                                                            .snap['open']);
                                                        if (widget
                                                            .snap['open']) {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    'Confirmation'),
                                                                content: Text(
                                                                    'Do you want to close further entries and assign matches?'),
                                                                actions: [
                                                                  ElevatedButton(
                                                                    child: Text(
                                                                        'Cancel'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(); // Close the dialog
                                                                    },
                                                                  ),
                                                                  ElevatedButton(
                                                                    child: Text(
                                                                        'Confirm'),
                                                                    onPressed:
                                                                        () async {
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'tournaments')
                                                                          .doc(widget.snap[
                                                                              'tournamentId'])
                                                                          .update({
                                                                        'open':
                                                                            false
                                                                      }).then(
                                                                              (value) {
                                                                        print(
                                                                            'Tournament open status updated successfully.');
                                                                      }).catchError(
                                                                              (error) {
                                                                        print(
                                                                            'Failed to update tournament open status: $error');
                                                                      });
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(); // Close the dialog
                                                                      Navigator.of(context).push(MaterialPageRoute(
                                                                          builder: (_) => TeamMatchupScreen(
                                                                                tournamentId: widget.snap['tournamentId'],
                                                                              )));
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      TeamMatchupScreen(
                                                                        tournamentId:
                                                                            widget.snap['tournamentId'],
                                                                      )));
                                                        }
                                                      } else {
                                                        if (widget
                                                            .snap['open']) {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      AddTeamForTournament(
                                                                        tournamentData:
                                                                            widget.snap,
                                                                      )));
                                                        } else {}
                                                      }
                                                    },
                                                    child: userModel!.mail !=
                                                            'admin@gmail.com'
                                                        ? Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFFf35a85),
                                                                  Color(
                                                                      0xFFee646a),
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                widget.fromAdmin
                                                                    ? 'View match card'
                                                                    : widget.snap['maxTeam'] !=
                                                                            0
                                                                        ? 'Add your team'
                                                                        : 'Entries closed.',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      fontSize *
                                                                          0.03,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.8),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ),
                                                )),
                                              ],
                                            )
                                          : Row(children: [
                                              Expanded(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (widget.fromAdmin) {
                                                      if (widget.snap['open']) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Confirmation'),
                                                              content: Text(
                                                                  'Do you want to close further entries and assign matches?'),
                                                              actions: [
                                                                ElevatedButton(
                                                                  child: Text(
                                                                      'Cancel'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // Close the dialog
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  child: Text(
                                                                      'Confirm'),
                                                                  onPressed:
                                                                      () async {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'tournaments')
                                                                        .doc(widget.snap[
                                                                            'tournamentId'])
                                                                        .update({
                                                                      'open':
                                                                          false
                                                                    }).then(
                                                                            (value) {
                                                                      print(
                                                                          'Tournament open status updated successfully.');
                                                                    }).catchError(
                                                                            (error) {
                                                                      print(
                                                                          'Failed to update tournament open status: $error');
                                                                    });
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // Close the dialog
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(MaterialPageRoute(
                                                                            builder: (_) => TeamMatchupScreen(
                                                                                  tournamentId: widget.snap['tournamentId'],
                                                                                )));
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    TeamMatchupScreen(
                                                                      tournamentId:
                                                                          widget
                                                                              .snap['tournamentId'],
                                                                    )));
                                                      }
                                                    } else {
                                                      if (widget.snap['open']) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    AddTeamForTournament(
                                                                      tournamentData:
                                                                          widget
                                                                              .snap,
                                                                    )));
                                                      } else {}
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color.fromARGB(255,
                                                              98, 157, 100),
                                                          Color(0xFF81C784),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        widget.fromAdmin
                                                            ? 'View match card'
                                                            : 'Already Joined Tournament',
                                                        style: TextStyle(
                                                          fontSize:
                                                              fontSize * 0.03,
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )),
                                            ]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    });
              }),
        ),
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirection: pi / 2,
            emissionFrequency: 0.1,
          ),
        ),
      ],
    );
  }
}
