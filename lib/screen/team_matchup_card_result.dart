import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamMatchupCardResult extends StatefulWidget {
  final bool teamA;
  final String team1Name;
  final String team2Name;
  int team1Points;
  int team2Points;
  final String matchId;
  final String team1Id;
  final String team2Id;

  TeamMatchupCardResult(
      {required this.team1Name,
      required this.team2Name,
      required this.team1Points,
      required this.team2Points,
      required this.matchId,
      required this.team1Id,
      required this.team2Id,
      required this.teamA});

  @override
  _TeamMatchupCardResultState createState() => _TeamMatchupCardResultState();
}

class _TeamMatchupCardResultState extends State<TeamMatchupCardResult> {
  void increasePoints(bool team1) async {
    try {
      print(team1 ? widget.team1Id : widget.team2Id);
      print('increasing');
      await FirebaseFirestore.instance
          .collection("tournaments")
          .doc(widget.matchId)
          .collection('players')
          .doc(team1 ? widget.team1Id : widget.team2Id)
          .update(
        {
          "points": FieldValue.increment(
            1,
          ),
        },
      );
    } catch (e) {
      e.toString();
    }
  }

  void nextLevel() {}

  void decreasePoints(bool team1) async {
    try {
      print('decrementing');
      await FirebaseFirestore.instance
          .collection("tournaments")
          .doc(widget.matchId)
          .collection('players')
          .doc(team1 ? widget.team1Id : widget.team2Id)
          .update(
        {
          "points": FieldValue.increment(
            -1,
          ),
        },
      );
    } catch (e) {
      e.toString();
    }
  }

  bool _isTeam1Winner = false;
  bool _isDeclared = false;

  @override
  Widget build(BuildContext context) {
    print(_isDeclared);
    print('hi');
    return Card(
      elevation: _isTeam1Winner ? 8.0 : 2.0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: (widget.teamA == true) ? Colors.green : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.add_circle_outline),

                      GestureDetector(
                        onLongPress: () {
                          print('long press');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Set Winner'),
                                content: Text(
                                    'Do you want to set ${widget.team1Name} as the winner?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      setState(() {
                                        _isTeam1Winner = true;
                                        _isDeclared = true;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          widget.team1Name,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),

                      // Icon(Icons.remove_circle_outline),
                    ],
                  ),
                  Text(
                    widget.team1Points.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: !widget.teamA ? Colors.green : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.),

                      GestureDetector(
                        onLongPress: () {
                          print('long press');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Set Winner'),
                                content: Text(
                                    'Do you want to set ${widget.team2Name} as the winner?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      setState(() {
                                        _isTeam1Winner = false;
                                        _isDeclared = true;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          widget.team2Name,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.team2Points.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
