// // ignore_for_file: prefer_const_literals_to_create_immutables

// import 'package:flutter/material.dart';

// class GameStatus extends StatefulWidget {
//   const GameStatus({super.key});

//   @override
//   State<GameStatus> createState() => _GameStatusState();
// }

// class _GameStatusState extends State<GameStatus> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Colors.black45,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: 50,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const AppBarIcon(
//                           iconData: Icons.minimize,
//                           color: Colors.white,
//                           iconColor: Colors.black)
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 SizedBox(
//                   height: 60,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.agriculture_rounded),
//                       const Text('Team A'),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 SizedBox(
//                   height: 60,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           // team = 'A';
//                           // _showSearchModal(context);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 const Text('0/0'),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: () {
//                     // team = 'B';
//                     // _showSearchModal(context);
//                   },
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 SizedBox(
//                   height: 60,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.agriculture_rounded),
//                       const Text('Team A'),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 120,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.minimize),
//                         onPressed: () {
//                           // team = 'A';
//                           // _showSearchModal(context);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AppBarIcon extends StatelessWidget {
//   const AppBarIcon({
//     super.key,
//     required this.iconData,
//     required this.color,
//     required this.iconColor,
//   });
//   final IconData iconData;
//   final Color color;
//   final Color iconColor;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Color.fromARGB(255, 236, 236, 236),
//             spreadRadius: 3,
//             blurRadius: 4,
//           )
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Icon(
//           iconData,
//           color: iconColor,
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamMatchupCard extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  int team1Points;
  int team2Points;
  final String matchId;
  final String team1Id;
  final String team2Id;

  TeamMatchupCard({
    required this.team1Name,
    required this.team2Name,
    required this.team1Points,
    required this.team2Points,
    required this.matchId,
    required this.team1Id,
    required this.team2Id,
  });

  @override
  _TeamMatchupCardState createState() => _TeamMatchupCardState();
}

class _TeamMatchupCardState extends State<TeamMatchupCard> {
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
              color: (_isTeam1Winner == true && _isDeclared == true)
                  ? Colors.green
                  : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.add_circle_outline),
                      IconButton(
                        onPressed: () {
                          if (true) {
                            setState(() {
                              widget.team1Points++;
                              increasePoints(true);
                            });
                          }
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                      ),

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
                      IconButton(
                        onPressed: () {
                          if (widget.team1Points > 0) {
                            setState(() {
                              widget.team1Points--;
                              decreasePoints(true);
                            });
                          }
                        },
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                      ),
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
              color:
                  !_isTeam1Winner && _isDeclared ? Colors.green : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.team2Points++;
                            increasePoints(false);
                          });
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                      ),
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

                      IconButton(
                        onPressed: () {
                          if (widget.team2Points > 0) {
                            setState(() {
                              widget.team2Points--;
                              decreasePoints(false);
                            });
                          }
                        },
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                      ),
                      // Icon(Icons.),
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
