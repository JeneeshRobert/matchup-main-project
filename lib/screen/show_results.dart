// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turfit/screen/personal_tournaments.dart';
import 'package:turfit/screen/team_matchup_card_result.dart';
import 'package:turfit/screen/bracket.dart';
import 'package:turfit/temp.dart';

class TeamMatchupScreenResult extends StatefulWidget {
  final String tournamentId;

  const TeamMatchupScreenResult({super.key, required this.tournamentId});
  @override
  _TeamMatchupScreenResultState createState() =>
      _TeamMatchupScreenResultState();
}

class _TeamMatchupScreenResultState extends State<TeamMatchupScreenResult> {
  int length = 0;
  List<int> mixList = [];
  List<QueryDocumentSnapshot<Object?>> documents = [];
  List<String> winners = [];
  List<String> losers = [];
  bool teamA = true;

  final List<TeamMatchupCard> matchups = [
    // TeamMatchupCard(
    //   team1Name: 'Team 1',
    //   team2Name: 'Team 2',
    //   team1Points: 5,
    //   team2Points: 3,
    // ),
    // TeamMatchupCard(
    //   team1Name: 'Team A',
    //   team2Name: 'Team B',
    //   team1Points: 1,
    //   team2Points: 2,
    // ),
    // TeamMatchupCard(
    //   team1Name: 'Team X',
    //   team2Name: 'Team Y',
    //   team1Points: 0,
    //   team2Points: 0,
    // ),
  ];

  void removeDocuments(List<String> documentIds, List<String> wdocumentIds,
      String tournamentId, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deleting Documents'),
          content: Text('Deleting in progress...'),
        );
      },
    );

    for (String documentId in documentIds) {
      await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentId)
          .collection('players')
          .doc(documentId)
          .delete();
    }

    for (String documentId in wdocumentIds) {
      await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentId)
          .collection('players')
          .doc(documentId)
          .update({
        'points': 0,
      });
    }

    DocumentReference orderRef = FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tournamentId)
        .collection('match')
        .doc('order');

    await orderRef.delete();

    Navigator.pop(context); // Close the dialog box

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deletion Complete'),
          content: Text('All documents deleted successfully.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);

// Close the dialog box
              },
            ),
          ],
        );
      },
    );
  }

  List<int> generateRandomMatches(int startNumber) {
    int randomNumber = Random().nextInt(startNumber) + 1;

    List<int> numberList = List<int>.generate(
        startNumber, (index) => (randomNumber + index) % startNumber);

    return (numberList);
  }

  void nextLevel() async {
    int counter = 0;
    print("xxxxxxxxxxxxx");
    print(mixList);
    for (int index = 0; index < (mixList.length / 2).ceil(); index++) {
      final documentData =
          documents[mixList[index + counter]].data() as Map<String, dynamic>;
      final nextDocumentData = documents[mixList[index + counter + 1]].data()
          as Map<String, dynamic>;
      print("documentData['points']");
      print(documentData['points']);
      print("nextDocumentData['points']");
      print(nextDocumentData['points']);
      if (documentData['points'] > nextDocumentData['points']) {
        teamA = true;
      } else {
        teamA = false;
      }
      counter += 1;
    }
    print("xxxxxxxxxxxxx");
  }

  Future checkAndUpdateOrder(String tournamentId) async {
    mixList = [];
    DocumentReference tournamentRef = FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tournamentId)
        .collection('match')
        .doc('order');

    DocumentSnapshot orderSnapshot = await tournamentRef.get();
    if (orderSnapshot.data() == null) {
      mixList = generateRandomMatches(length);
      await tournamentRef.set({'currentorder': mixList});
    } else {
      final data = orderSnapshot.data() as Map<String, dynamic>;
      final x = (data['currentorder']);
      for (var num in x) {
        mixList.add(num);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team results confirm'),
        actions: [
          IconButton(
            onPressed: () {
              print(winners);
              print(losers);
              removeDocuments(losers, winners, widget.tournamentId, context);
            },
            icon: Icon(Icons.next_plan_outlined),
          ),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        child: FutureBuilder<dynamic>(
            future: checkAndUpdateOrder(widget.tournamentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('tournaments')
                        .doc(widget.tournamentId)
                        .collection('players')
                        .get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      documents = snapshot.data!.docs;

                      length = (snapshot.data!.size);
                      print('mixlist available inside $mixList');
                      // mixList = (generateRandomMatches(length));
                      print(mixList);
                      if ((length) % 2 == 0) {
                        int counter = 0;
                        return Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height - 100,
                              child: ListView.builder(
                                itemCount: (length / 2).ceil(),
                                itemBuilder: (BuildContext context, int index) {
                                  print(mixList[index + counter]);
                                  final documentData =
                                      documents[mixList[index + counter]].data()
                                          as Map<String, dynamic>;
                                  final nextDocumentData =
                                      documents[mixList[index + counter + 1]]
                                          .data() as Map<String, dynamic>;
                                  counter += 1;
                                  print('counter = $counter');
                                  if (documentData['teamId'] != 'temp') {
                                    if (documentData['points'] >
                                        nextDocumentData['points']) {
                                      teamA = true;
                                      winners.add(documentData['teamId']);
                                      losers.add(nextDocumentData['teamId']);
                                    } else {
                                      teamA = false;
                                      losers.add(documentData['teamId']);
                                      winners.add(nextDocumentData['teamId']);
                                    }
                                    return TeamMatchupCardResult(
                                      teamA: teamA,
                                      team1Name: documentData['teamName'],
                                      team2Name: nextDocumentData['teamName'],
                                      team1Points: documentData['points'],
                                      team2Points: nextDocumentData['points'],
                                      matchId: widget.tournamentId,
                                      team1Id: documentData['teamId'],
                                      team2Id: nextDocumentData['teamId'],
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        int counter = 0;
                        print('odd');
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: (length / 2).ceil(),
                                itemBuilder: (BuildContext context, int index) {
                                  print('index $index');
                                  if ((index + 1) == (length / 2).ceil()) {
                                    print('single one');
                                    final documentData =
                                        documents[mixList[index + counter]]
                                            .data() as Map<String, dynamic>;
                                    print(documentData);
                                    winners.add(documentData['teamId']);
                                    return SizedBox(
                                      height: 70,
                                      child: Card(
                                        color: Colors.green,
                                        elevation: 2.0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              documentData['teamName'],
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    print(mixList[index + counter]);
                                    final documentData =
                                        documents[mixList[index + counter]]
                                            .data() as Map<String, dynamic>;
                                    final nextDocumentData =
                                        documents[mixList[index + counter + 1]]
                                            .data() as Map<String, dynamic>;
                                    counter += 1;
                                    print('counter = $counter');
                                    if (documentData['teamId'] != 'temp') {
                                      if (documentData['points'] >
                                          nextDocumentData['points']) {
                                        teamA = true;
                                        winners.add(documentData['teamId']);
                                        losers.add(nextDocumentData['teamId']);
                                      } else {
                                        teamA = false;
                                        losers.add(documentData['teamId']);
                                        winners.add(nextDocumentData['teamId']);
                                      }
                                      return TeamMatchupCardResult(
                                        teamA: teamA,
                                        team1Name: documentData['teamName'],
                                        team2Name: nextDocumentData['teamName'],
                                        team1Points: documentData['points'],
                                        team2Points: nextDocumentData['points'],
                                        matchId: widget.tournamentId,
                                        team1Id: documentData['teamId'],
                                        team2Id: nextDocumentData['teamId'],
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    });
              }
              return Container();
            }),
      ),
    );
  }
}
