// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:turfit/auth/user_provider.dart';

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
  Map<String, dynamic> toJson() => {
        'userID': id,
        'name': name,
      };
}

class DetailsPage extends StatefulWidget {
  var snap;
  DetailsPage({super.key, required this.snap});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<User> usersA = [];
  List<User> usersB = [];

  List<String> namesA = [];
  List<String> namesB = [];

  Future<bool> isMatchIdInUserMatches(String matchId) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final userMatches =
        await userDoc.get().then((doc) => doc.data()?['participatedMatches']);
    print(userMatches);
    print(matchId);

    return userMatches != null && userMatches.contains(matchId);
  }

  Future<String> addMatchData(
      {required String matchID,
      required String team,
      required String name}) async {
    String res = "Err";
    final User user =
        User(id: FirebaseAuth.instance.currentUser!.uid, name: name);

    try {
      DocumentSnapshot matchSnapshot = await FirebaseFirestore.instance
          .collection("matches")
          .doc(matchID)
          .get();
      final data = matchSnapshot.data() as Map<String, dynamic>;
      int seats = data['seats$team'];

      if (seats > 0) {
        await FirebaseFirestore.instance
            .collection("matches")
            .doc(matchID)
            .update({
          "seats$team": FieldValue.increment(-1),
        });
        await FirebaseFirestore.instance
            .collection("matches")
            .doc(matchID)
            .update({
          "seatsLeft": FieldValue.increment(-1),
        });

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

        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(
            {
              "participatedMatches": FieldValue.arrayUnion(
                [matchID],
              ),
            },
          );
        } catch (e) {
          e.toString();
        }
        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update(
            {
              "matches": FieldValue.arrayUnion(
                [matchID],
              ),
            },
          );
        } catch (e) {
          e.toString();
        }
      } else {
        final snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'sorry',
            message: 'Seats are already filled.',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      print(e.toString());
    }

    // final snackBar = SnackBar(
    //   /// need to set following properties for best effect of awesome_snackbar_content
    //   elevation: 0,
    //   behavior: SnackBarBehavior.floating,
    //   backgroundColor: Colors.transparent,
    //   content: AwesomeSnackbarContent(
    //     title: 'Yay',
    //     message: 'Joined game. You will be notified when game is live.',

    //     /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
    //     contentType: ContentType.success,
    //   ),
    // );

    // ScaffoldMessenger.of(context)
    //   ..hideCurrentSnackBar()
    //   ..showSnackBar(snackBar);
    res = "success";
    return res;
  }

  Future checkForNotifications({required String matchID}) async {
    print('starting notifications');
    //for notifications
    try {
      DocumentSnapshot matchSnapshot = await FirebaseFirestore.instance
          .collection("matches")
          .doc(matchID)
          .get();
      final data = matchSnapshot.data() as Map<String, dynamic>;
      int seats = data['seatsLeft'];
      print("seats are left $seats");
      if (seats == 0) {
        print('seats are filled');
        CollectionReference playersCollection = FirebaseFirestore.instance
            .collection('matches')
            .doc(matchID)
            .collection('players');

        QuerySnapshot querySnapshot = await playersCollection.get();
        CollectionReference notifyCollection =
            FirebaseFirestore.instance.collection('notifications');
        print('got ${querySnapshot.docs.length} docs');
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          List<dynamic> list = data['players'];
          print("one documentSnapshot");
          print(list);
          for (var map in list) {
            String userID = map['userID'];
            print('notifying players $userID');

            DocumentReference userDocument = notifyCollection.doc(userID);

            await userDocument.update({
              'notifications': FieldValue.arrayUnion(
                  ['Hey! Match is filled. See you at the end of the match.']),
            });
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  late var data;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;
    final fontSize = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder<bool>(
          future: isMatchIdInUserMatches(widget.snap['matchID']),
          builder: (context, snapshotData) {
            if (snapshotData.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.flickr(
                    leftDotColor: Color(0xFFEB455F),
                    rightDotColor: Color(0xFF2B3467),
                    size: 30),
              );
            } else if (snapshotData.hasError) {
              return Text('Error: ${snapshotData.error}');
            }
            print(snapshotData.data);
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('matches')
                    .doc(widget.snap['matchID'])
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
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
                              colors: [Color(0xFF009bdd), Color(0xFF02dac1)],
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.3,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.7,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: fontSize * 0.035,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                        SizedBox(
                                          height: fontSize * 0.03,
                                        ),
                                        Text(
                                          data!['description'],
                                          style: TextStyle(
                                            fontSize: fontSize * 0.03,
                                            color:
                                                Colors.white.withOpacity(0.8),
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
                                            fontSize: fontSize * 0.035,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                        SizedBox(
                                          height: fontSize * 0.03,
                                        ),
                                        Text(
                                          data['location'],
                                          style: TextStyle(
                                            fontSize: fontSize * 0.03,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                        SizedBox(
                                          height: fontSize * 0.02,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 600,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('matches')
                                                  .doc(widget.snap['matchID'])
                                                  .collection('players')
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot) {
                                                if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                }
                                                switch (
                                                    snapshot.connectionState) {
                                                  case ConnectionState.waiting:
                                                    return Text('Loading...');
                                                  default:
                                                    final players =
                                                        snapshot.data!.docs;
                                                    return ListView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: players.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        final playerData =
                                                            players[index]
                                                                    ['players']
                                                                as List<
                                                                    dynamic>;
                                                        final playerMaps =
                                                            playerData;
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            child: Table(
                                                              defaultVerticalAlignment:
                                                                  TableCellVerticalAlignment
                                                                      .middle,
                                                              children: [
                                                                // Table header row
                                                                TableRow(
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[300],
                                                                      ),
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Team ${index + 1} (${playerMaps.length})',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                // Table data rows
                                                                ...playerMaps
                                                                    .map(
                                                                  (name) =>
                                                                      TableRow(
                                                                    children: [
                                                                      Container(
                                                                        decoration:
                                                                            BoxDecoration(color: Colors.grey[100]),
                                                                        padding:
                                                                            EdgeInsets.all(8.0),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(name['name'].toString()),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
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
                          left: MediaQuery.of(context).size.width * 0.05,
                          top: MediaQuery.of(context).size.height * 0.25,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Color(0xFF2b2e3b),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    data['name'],
                                    style: TextStyle(
                                      fontSize: fontSize * 0.042,
                                      color: Colors.white.withOpacity(0.8),
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
                                            FontAwesomeIcons.calendarDays,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            size: fontSize * 0.05,
                                          ),
                                          SizedBox(
                                            height: fontSize * 0.02,
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy').format(
                                              data['date'].toDate(),
                                            ),
                                            style: TextStyle(
                                              fontSize: fontSize * 0.025,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.peopleLine,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            size: fontSize * 0.05,
                                          ),
                                          SizedBox(
                                            height: fontSize * 0.02,
                                          ),
                                          Text(
                                            '${data["seats"]} / Team',
                                            style: TextStyle(
                                              fontSize: fontSize * 0.025,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.clock,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            size: fontSize * 0.05,
                                          ),
                                          SizedBox(
                                            height: fontSize * 0.02,
                                          ),
                                          Text(
                                            DateFormat('hh:mm').format(
                                              data['date'].toDate(),
                                            ),
                                            style: TextStyle(
                                              fontSize: fontSize * 0.025,
                                              color:
                                                  Colors.white.withOpacity(0.8),
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
                          left: MediaQuery.of(context).size.width * 0.46,
                          top: MediaQuery.of(context).size.height * 0.16,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.12,
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
                            height: MediaQuery.of(context).size.height * 0.08,
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
                                      userModel!.mail != 'admin@gmail.com'
                                          ? Expanded(
                                              child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  String x = await addMatchData(
                                                      matchID: widget
                                                          .snap['matchID'],
                                                      team: 'A',
                                                      name: userModel.username);
                                                  print(x);
                                                  await checkForNotifications(
                                                      matchID: widget
                                                          .snap['matchID']);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color.fromARGB(
                                                            255, 98, 157, 100),
                                                        Color(0xFF81C784),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Join Team A',
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
                                            ))
                                          : Container(),
                                      userModel.mail != 'admin@gmail.com'
                                          ? Expanded(
                                              child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  String x = await addMatchData(
                                                      matchID: widget
                                                          .snap['matchID'],
                                                      team: 'B',
                                                      name: userModel.username);
                                                  print(x);
                                                  await checkForNotifications(
                                                      matchID: widget
                                                          .snap['matchID']);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color.fromARGB(
                                                            255, 98, 157, 100),
                                                        Color(0xFF81C784),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Join Team B',
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
                                            ))
                                          : Container(),
                                    ],
                                  )
                                : Row(children: [
                                    userModel!.mail != 'admin@gmail.com'
                                        ? Expanded(
                                            child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                // addMatchData(
                                                //     matchID: widget.snap['matchID'],
                                                //     team: 'A',
                                                //     name: userModel!.username);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 98, 157, 100),
                                                      Color(0xFF81C784),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Already Joined',
                                                    style: TextStyle(
                                                      fontSize: fontSize * 0.03,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                        : Container(),
                                  ]),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }
}
