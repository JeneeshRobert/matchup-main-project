// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turfit/screen/details_screen.dart';
import 'package:turfit/utils/dynamic_icon.dart';
import 'package:turfit/utils/loading_screen.dart';

class ColorPair {
  Color color1;
  Color color2;

  ColorPair({required this.color1, required this.color2});
}

class AllList extends StatefulWidget {
  AllList({super.key});

  @override
  State<AllList> createState() => _AllListState();
}

class _AllListState extends State<AllList> {
  bool searchBox = false;
  String searchText = '';

  List<String> docIDs = [];

  int totalPlayerCount = 0;
  int totalPlayerCountA = 0;
  int totalPlayerCountB = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future getdocIDs() async {
    await _firestore
        .collection('matches')
        // .orderBy('age', descending: false)
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              docIDs.add(document.reference.id);
            }));
  }

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
    docIDs.clear();
  }

  List<String> sports = [
    "All",
    "Golf",
    "Skiing",
  ];

  final List<ColorPair> colorPairs = [
    ColorPair(color1: Color(0xFFa091fb), color2: Color(0xFFc895fa)),
    ColorPair(color1: Color(0xFF40aa84), color2: Color(0xFF8ac481)),
    ColorPair(color1: Color(0xFFf48a80), color2: Color(0xFFf9ab77)),
  ];

  String selectedOption = 'All';

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Options'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildOption('All'),
                _buildOption('Completed'),
                _buildOption('Today'),
                _buildOption('Upcoming'),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        selectedOption = value;
        // Do something with the selected option, such as filter the list
      }
    });
  }

  Widget _buildOption(String option) {
    return ListTile(
      title: Text(option),
      onTap: () {
        Navigator.of(context)
            .pop(option); // Close the dialog and return the selected option
      },
    );
  }

  String sport = 'All';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.04;

    docIDs = [];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFe5e5fe),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 8.0,
              ),
              child: DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  showSelectedItems: true,
                  disabledItemFn: (String s) => s.startsWith('I'),
                ),
                items: sports,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    labelText: 'select sport',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    sport = val!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 8.0,
              ),
              child: sport == 'All'
                  ? FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('matches')
                          .get(),
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          print('hdi');

                          // return SizedBox(
                          //   height: 300,
                          //   child: ListView.builder(
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: 3,
                          //     itemBuilder: (BuildContext context, int index) {
                          //       return LoadingScreen();
                          //     },
                          //   ),
                          // );
                        } else {
                          print('hdi');

                          final sportsList =
                              (snapshot.data! as QuerySnapshot).docs.toList();
                          return SizedBox(
                            height: 400,
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3 / 3,
                              ),
                              itemCount: sportsList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final snap = sportsList[index];
                                final random = Random();
                                final colorPair = colorPairs[
                                    random.nextInt(colorPairs.length)];

                                final gradient = LinearGradient(
                                  colors: [colorPair.color1, colorPair.color2],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                );
                                //
                                CollectionReference matches =
                                    _firestore.collection('matches');

                                return FutureBuilder<DocumentSnapshot>(
                                  future: matches
                                      .doc(sportsList[index]['matchID'])
                                      .get(),
                                  builder: (((context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      Map<String, dynamic> snap = snapshot.data!
                                          .data() as Map<String, dynamic>;

                                      if (snap['name']
                                          .toString()
                                          .toLowerCase()
                                          .contains(searchText)) {
                                        return FutureBuilder<Map<String, int>>(
                                          future: getTotalPlayerCount(
                                              snap['matchID']),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              Map<String, int>
                                                  totalPlayerCounts =
                                                  snapshot.data!;

                                              int playerCountA =
                                                  totalPlayerCounts['A']!;
                                              int playerCountB =
                                                  totalPlayerCounts['B']!;
                                              int totalPlayerCount =
                                                  playerCountA + playerCountB;

                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          DetailsPage(
                                                        snap: snap,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 170,
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  decoration: BoxDecoration(
                                                    gradient: gradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Chip(
                                                              backgroundColor:
                                                                  colorPair
                                                                      .color1
                                                                      .withOpacity(
                                                                          0.8),
                                                              label: Text(
                                                                  snap['name']),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(snap[
                                                                        'seatsLeft']
                                                                    .toString()),
                                                                Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  height: 20.0,
                                                                  width: 20.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    width: 15,
                                                                    height: 15,
                                                                    margin: EdgeInsets
                                                                        .all(3),
                                                                    child:
                                                                        CircleAvatar(
                                                                      backgroundColor: snap['seatsLeft'] == 0
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .greenAccent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            PlayerCountIcon(
                                                              iconData: Icons
                                                                  .sports_soccer, // Replace with your desired icon
                                                              documentReference: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'matches')
                                                                  .doc(snap[
                                                                      'matchID'])
                                                                  .collection(
                                                                      'players')
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
                                                                  .collection(
                                                                      'matches')
                                                                  .doc(snap[
                                                                      'matchID'])
                                                                  .collection(
                                                                      'players')
                                                                  .doc('B'),
                                                              maxSize: 11,
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Column(children: [
                                                                Text(
                                                                  'Team A',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          size),
                                                                ),
                                                                Text(
                                                                  'Team B',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          size),
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
                                                                        fontSize:
                                                                            size),
                                                                  ),
                                                                  Text(
                                                                    '$playerCountB',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            size),
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
                                        Container();
                                      }
                                    }
                                    return Container();
                                  })),
                                );
                              },
                            ),
                          );
                        }
                        return Container();
                      }),
                    )
                  : FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('matches')
                          .where('name', isEqualTo: sport)
                          .get(),
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          print('hi');
                          // return SizedBox(
                          //   height: 300,
                          //   child: ListView.builder(
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: 3,
                          //     itemBuilder: (BuildContext context, int index) {
                          //       return LoadingScreen();
                          //     },
                          //   ),
                          // );
                        } else {
                          final sportsList =
                              (snapshot.data! as QuerySnapshot).docs.toList();
                          return SizedBox(
                            height: 400,
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3 / 3,
                              ),
                              itemCount: sportsList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final snap = sportsList[index];
                                final random = Random();
                                final colorPair = colorPairs[
                                    random.nextInt(colorPairs.length)];

                                final gradient = LinearGradient(
                                  colors: [colorPair.color1, colorPair.color2],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                );
                                //
                                CollectionReference matches =
                                    _firestore.collection('matches');

                                return FutureBuilder<DocumentSnapshot>(
                                  future: matches
                                      .doc(sportsList[index]['matchID'])
                                      .get(),
                                  builder: (((context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      Map<String, dynamic> snap = snapshot.data!
                                          .data() as Map<String, dynamic>;

                                      if (snap['name']
                                          .toString()
                                          .toLowerCase()
                                          .contains(searchText)) {
                                        return FutureBuilder<Map<String, int>>(
                                          future: getTotalPlayerCount(
                                              snap['matchID']),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              Map<String, int>
                                                  totalPlayerCounts =
                                                  snapshot.data!;

                                              int playerCountA =
                                                  totalPlayerCounts['A']!;
                                              int playerCountB =
                                                  totalPlayerCounts['B']!;
                                              int totalPlayerCount =
                                                  playerCountA + playerCountB;

                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          DetailsPage(
                                                        snap: snap,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 170,
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  decoration: BoxDecoration(
                                                    gradient: gradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Chip(
                                                              backgroundColor:
                                                                  colorPair
                                                                      .color1
                                                                      .withOpacity(
                                                                          0.8),
                                                              label: Text(
                                                                  snap['name']),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(snap[
                                                                        'seatsLeft']
                                                                    .toString()),
                                                                Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  height: 20.0,
                                                                  width: 20.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    width: 15,
                                                                    height: 15,
                                                                    margin: EdgeInsets
                                                                        .all(3),
                                                                    child:
                                                                        CircleAvatar(
                                                                      backgroundColor: snap['seatsLeft'] == 0
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .greenAccent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            PlayerCountIcon(
                                                              iconData: Icons
                                                                  .sports_soccer, // Replace with your desired icon
                                                              documentReference: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'matches')
                                                                  .doc(snap[
                                                                      'matchID'])
                                                                  .collection(
                                                                      'players')
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
                                                                  .collection(
                                                                      'matches')
                                                                  .doc(snap[
                                                                      'matchID'])
                                                                  .collection(
                                                                      'players')
                                                                  .doc('B'),
                                                              maxSize: 11,
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Column(children: [
                                                                Text(
                                                                  'Team A',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          size),
                                                                ),
                                                                Text(
                                                                  'Team B',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          size),
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
                                                                        fontSize:
                                                                            size),
                                                                  ),
                                                                  Text(
                                                                    '$playerCountB',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            size),
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
                                        Container();
                                      }
                                    }
                                    return Container();
                                  })),
                                );
                              },
                            ),
                          );
                        }
                        return Container();
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchBar(String placehold) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: SizedBox(
        width: 250,
        child: CupertinoSearchTextField(
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          borderRadius: BorderRadius.circular(10.0),
          placeholder: placehold,
        ),
      ),
    );
  }
}
