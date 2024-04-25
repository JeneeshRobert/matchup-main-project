// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:turfit/utils/am_pm.dart';
import 'package:turfit/utils/hours.dart';
import 'package:turfit/utils/minutes.dart';
import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String photourl;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.photourl});
  Map<String, dynamic> toJson() => {
        'userID': id,
        'name': name,
        'email': email,
        'photourl': photourl,
      };
}

class AddGame extends StatefulWidget {
  List<User> usersA = [];
  List<User> usersB = [];
  final String sport;
  final String college;
  final int num;

  AddGame({
    super.key,
    required this.sport,
    required this.num,
    required this.college,
    this.usersA = const [],
    this.usersB = const [],
  });

  @override
  State<AddGame> createState() => _AddGameState();
}

class _AddGameState extends State<AddGame> {
  List<User> usersA = [];
  List<User> usersB = [];

  List<String> namesA = [];
  List<String> namesB = [];
  String team = "";
  List<User> _users = [];
  List<User> _searchResults = [];
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locController = TextEditingController();

  bool _isLoading = false;
  DateTime _selectedValue = DateTime.now();
  late FixedExtentScrollController? _controller;
  int hour = 0;
  int minute = 0;
  bool am = true;
  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _controller = FixedExtentScrollController();
  }

  Future<bool> isMatchIdInUserMatches(String matchId) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final userMatches =
        await userDoc.get().then((doc) => doc.data()?['matches']);

    return userMatches != null && userMatches.contains(matchId);
  }

  Future<String> addMatchData() async {
    String res = 'Error';
    if (_descController.text.isNotEmpty && _locController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text('Publishing Game'),
      //       content: Text('Please wait...'),
      //     );
      //   },
      // );
      String matchId = const Uuid().v1();
      print(usersA);
      print(usersB);

      CollectionReference matchesCollection =
          FirebaseFirestore.instance.collection('matches');

      DocumentReference newMatchDoc = matchesCollection.doc(matchId);

      await newMatchDoc.set({
        'name': widget.sport,
        'matchID': matchId,
        'seats': widget.num,
        'seatsA': widget.num,
        'seatsB': widget.num,
        'date': _selectedValue,
        'college': widget.college,
        'seatsLeft': widget.num * 2,
        'description': _descController.text,
        'location': _locController.text,
      });

      await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .collection('players')
          .doc('A')
          .set({
        'players': [],
      });
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .collection('players')
          .doc('B')
          .set({
        'players': [],
      });

      DocumentReference playerADoc = FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .collection('players')
          .doc('A');
      for (var player in usersA) {
        try {
          await FirebaseFirestore.instance
              .collection("matches")
              .doc(matchId)
              .collection('players')
              .doc('A')
              .update(
            {
              "players": FieldValue.arrayUnion(
                [player.toJson()],
              ),
            },
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(player.id)
              .update(
            {
              'participatedMatches': FieldValue.arrayUnion(
                [
                  matchId,
                ],
              ),
            },
          );
        } catch (e) {
          e.toString();
        }

        try {
          print('decrementing');
          DocumentSnapshot matchSnapshot = await FirebaseFirestore.instance
              .collection("matches")
              .doc(matchId)
              .get();
          final data = matchSnapshot.data() as Map<String, dynamic>;
          int seats = data['seats'];

          if (seats > 0) {
            await FirebaseFirestore.instance
                .collection("matches")
                .doc(matchId)
                .update({
              "seatsA": FieldValue.increment(-1),
            });
            await FirebaseFirestore.instance
                .collection("matches")
                .doc(matchId)
                .update({
              "seatsLeft": FieldValue.increment(-1),
            });
          } else {
            // Display Snackbar indicating no seats left
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No seats left')),
            );
          }
        } catch (e) {
          print(e.toString());
        }
      }

      playerADoc = FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .collection('players')
          .doc('B');
      for (var player in usersB) {
        try {
          await FirebaseFirestore.instance
              .collection("matches")
              .doc(matchId)
              .collection('players')
              .doc('B')
              .update(
            {
              "players": FieldValue.arrayUnion(
                [player.toJson()],
              ),
            },
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(player.id)
              .update(
            {
              'participatedMatches': FieldValue.arrayUnion(
                [
                  matchId,
                ],
              ),
            },
          );
        } catch (e) {
          e.toString();
        }

        try {
          print('decrementing');
          await FirebaseFirestore.instance
              .collection("matches")
              .doc(matchId)
              .update(
            {
              "seatsB": FieldValue.increment(
                -1,
              ),
            },
          );
        } catch (e) {
          e.toString();
        }

        try {
          print('decrementing');
          await FirebaseFirestore.instance
              .collection("matches")
              .doc(matchId)
              .update(
            {
              "seatsLeft": FieldValue.increment(
                -1,
              ),
            },
          );
        } catch (e) {
          e.toString();
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          'matches': FieldValue.arrayUnion(
            [
              matchId,
            ],
          ),
        },
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {
          'conductedMatches': FieldValue.arrayUnion(
            [
              matchId,
            ],
          ),
        },
      );
      setState(() {
        _isLoading = false;
      });
      res = "success";
    }

    return res;
  }

  Future<void> _fetchUsers() async {
    // Fetch users from Firebase
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Convert fetched data to User objects
    List<User> users = snapshot.docs
        .map(
          (doc) => User(
            id: doc.id,
            name: (doc.data() as Map<String, dynamic>)['username'],
            email: (doc.data() as Map<String, dynamic>)['email'],
            photourl: (doc.data() as Map<String, dynamic>)['photourl'],
          ),
        )
        .toList();

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _searchUsers(String searchText) {
    List<User> searchResults = _users
        .where((user) =>
            user.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    setState(() {
      _searchResults = searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    for (var x in widget.usersA) {
      usersA.add(x);
      namesA.add(x.name);
    }
    for (var x in widget.usersB) {
      usersB.add(x);
      namesB.add(x.name);
    }
    final fontSize = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF009bdd), Color(0xFF02dac1)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          _selectedValue = _selectedValue
                              .add(Duration(hours: hour, minutes: minute));
                          if (!am) {
                            _selectedValue =
                                _selectedValue.add(Duration(hours: 12));
                          }
                          String x = await addMatchData();
                          print(x);
                          if (x == "success") {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            final snackBar = SnackBar(
                              /// need to set following properties for best effect of awesome_snackbar_content
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Yay',
                                message:
                                    'Game published. Go to personal games.',

                                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                contentType: ContentType.success,
                              ),
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(snackBar);
                          } else {
                            final snackBar = SnackBar(
                              /// need to set following properties for best effect of awesome_snackbar_content
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'uh oh',
                                message: 'fill details correctly.',

                                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                contentType: ContentType.failure,
                              ),
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(snackBar);
                          }
                        },
                        child: SizedBox(
                          width: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF81C784),
                                    Color(0xFF81C784),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                    child: _isLoading
                                        ? LoadingAnimationWidget.flickr(
                                            leftDotColor: Color(0xFFEB455F),
                                            rightDotColor: Color(0xFF2B3467),
                                            size: 25)
                                        : Text(
                                            'Publish now',
                                            style: TextStyle(
                                              fontSize: fontSize * 0.03,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Team A'),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          team = 'A';
                          _showSearchModal(context);
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('-'),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          team = 'B';
                          _showSearchModal(context);
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Team B'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${usersA.length} / ${widget.num}'),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('-'),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('${usersB.length} / ${widget.num}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                height: 800,
                decoration: BoxDecoration(
                  color: Color(0xFF181920),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: fontSize * 0.06,
                    right: fontSize * 0.06,
                    top: fontSize * 0.06,
                  ),
                  child: Column(
                    children: [
                      DatePicker(
                        DateTime.now(),
                        initialSelectedDate: DateTime.now(),
                        selectionColor: Colors.black,
                        dateTextStyle: TextStyle(color: Colors.white),
                        monthTextStyle: TextStyle(color: Colors.white),
                        selectedTextColor: Colors.white,
                        onDateChange: (date) {
                          // New date selected
                          setState(() {
                            _selectedValue = date;
                            print(_selectedValue);
                          });
                        },
                      ),
                      SizedBox(
                        height: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // hours wheel
                            Container(
                              width: 70,
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (value) {
                                  hour = value;
                                },
                                controller: _controller,
                                itemExtent: 50,
                                perspective: 0.005,
                                diameterRatio: 1.2,
                                physics: FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 13,
                                  builder: (context, index) {
                                    return MyHours(
                                      hours: index,
                                    );
                                  },
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 10,
                            ),

                            Container(
                              width: 70,
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (value) {
                                  minute = value;
                                },
                                itemExtent: 50,
                                perspective: 0.005,
                                diameterRatio: 1.2,
                                physics: FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 60,
                                  builder: (context, index) {
                                    return MyMinutes(
                                      mins: index,
                                    );
                                  },
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 15,
                            ),

                            // am or pm
                            Container(
                              width: 70,
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (value) {
                                  value == 0 ? am = true : am = false;
                                  print(am);
                                },
                                itemExtent: 50,
                                perspective: 0.005,
                                diameterRatio: 1.2,
                                physics: FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 2,
                                  builder: (context, index) {
                                    if (index == 0) {
                                      return AmPm(
                                        isItAm: true,
                                      );
                                    } else {
                                      return AmPm(
                                        isItAm: false,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: fontSize * 0.06,
                      ),
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 185, 184, 184),
                              spreadRadius: 0,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _descController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Say something about this match...',
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 185, 184, 184),
                              spreadRadius: 0,
                              blurRadius: 4,
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color(0xFFfcf4e4),
                                    ),
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.location_on,
                                        size: 16,
                                      ),
                                      color: Color(0xFF756d54),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width:
                                        MediaQuery.of(context).size.width - 150,
                                    child: TextField(
                                      controller: _locController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Location',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.chevron_right_sharp),
                            ],
                          ),
                        ),
                      ),
                      //

                      SizedBox(
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Table(
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
                                        'Team A (${namesA.length})',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Table data rows
                              ...namesA.map(
                                (name) => TableRow(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: namesA.indexOf(name) % 2 == 0
                                            ? Colors.grey[100]
                                            : Colors.white,
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(name),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: fontSize * 0.06,
                      ),
                      SizedBox(
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Table(
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
                                        'Team B  (${namesB.length})',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Table data rows
                              ...namesB.map(
                                (name) => TableRow(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: namesB.indexOf(name) % 2 == 0
                                            ? Colors.grey[100]
                                            : Colors.white,
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(name),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: fontSize * 0.06,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    ));
    return Scaffold(
      body: SafeArea(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _selectedValue = _selectedValue
                              .add(Duration(hours: hour, minutes: minute));
                          if (!am) {
                            _selectedValue =
                                _selectedValue.add(Duration(hours: 12));
                          }
                          addMatchData();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: SizedBox(
                          width: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 98, 157, 100),
                                    Color(0xFF81C784),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: Text(
                                    'Publish now',
                                    style: TextStyle(
                                      fontSize: fontSize * 0.03,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Team A'),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          team = 'A';
                          _showSearchModal(context);
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('-'),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          team = 'B';
                          _showSearchModal(context);
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Team B'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${usersA.length} / ${widget.num}'),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('-'),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('${usersB.length} / ${widget.num}'),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFF181920),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: fontSize * 0.06,
                    right: fontSize * 0.06,
                    top: fontSize * 0.06,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        DatePicker(
                          DateTime.now(),
                          initialSelectedDate: DateTime.now(),
                          selectionColor: Colors.black,
                          dateTextStyle: TextStyle(color: Colors.white),
                          monthTextStyle: TextStyle(color: Colors.white),
                          selectedTextColor: Colors.white,
                          onDateChange: (date) {
                            // New date selected
                            setState(() {
                              _selectedValue = date;
                              print(_selectedValue);
                            });
                          },
                        ),
                        SizedBox(
                          height: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // hours wheel
                              Container(
                                width: 70,
                                child: ListWheelScrollView.useDelegate(
                                  onSelectedItemChanged: (value) {
                                    hour = value;
                                  },
                                  controller: _controller,
                                  itemExtent: 50,
                                  perspective: 0.005,
                                  diameterRatio: 1.2,
                                  physics: FixedExtentScrollPhysics(),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: 13,
                                    builder: (context, index) {
                                      return MyHours(
                                        hours: index,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 10,
                              ),

                              Container(
                                width: 70,
                                child: ListWheelScrollView.useDelegate(
                                  onSelectedItemChanged: (value) {
                                    minute = value;
                                  },
                                  itemExtent: 50,
                                  perspective: 0.005,
                                  diameterRatio: 1.2,
                                  physics: FixedExtentScrollPhysics(),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: 60,
                                    builder: (context, index) {
                                      return MyMinutes(
                                        mins: index,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 15,
                              ),

                              // am or pm
                              Container(
                                width: 70,
                                child: ListWheelScrollView.useDelegate(
                                  onSelectedItemChanged: (value) {
                                    value == 0 ? am = true : am = false;
                                    print(am);
                                  },
                                  itemExtent: 50,
                                  perspective: 0.005,
                                  diameterRatio: 1.2,
                                  physics: FixedExtentScrollPhysics(),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: 2,
                                    builder: (context, index) {
                                      if (index == 0) {
                                        return AmPm(
                                          isItAm: true,
                                        );
                                      } else {
                                        return AmPm(
                                          isItAm: false,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: fontSize * 0.06,
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 185, 184, 184),
                                spreadRadius: 0,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _descController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Say something about this match...',
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 185, 184, 184),
                                spreadRadius: 0,
                                blurRadius: 4,
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color(0xFFfcf4e4),
                                      ),
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.location_on,
                                          size: 16,
                                        ),
                                        color: Color(0xFF756d54),
                                      ),
                                    ),
                                    TextField(
                                      controller: _locController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                            'Say something about this match...',
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right_sharp),
                              ],
                            ),
                          ),
                        ),
                        //

                        SizedBox(
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Table(
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
                                          'Team A (${namesA.length})',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Table data rows
                                ...namesA.map(
                                  (name) => TableRow(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: namesA.indexOf(name) % 2 == 0
                                              ? Colors.grey[100]
                                              : Colors.white,
                                        ),
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(name),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: fontSize * 0.06,
                        ),
                        SizedBox(
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Table(
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
                                          'Team B  (${namesB.length})',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Table data rows
                                ...namesB.map(
                                  (name) => TableRow(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: namesB.indexOf(name) % 2 == 0
                                              ? Colors.grey[100]
                                              : Colors.white,
                                        ),
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(name),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: fontSize * 0.06,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Positioned(
            //   left: MediaQuery.of(context).size.width * 0.46,
            //   top: MediaQuery.of(context).size.height * 0.16,
            //   child: Container(
            //     height: MediaQuery.of(context).size.height * 0.2,
            //     width: MediaQuery.of(context).size.width * 0.12,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       color: Color(0xFF2b2e3b),
            //     ),
            //     child: Center(
            //       child: FaIcon(
            //         FontAwesomeIcons.basketball,
            //         size: 35,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.arrowLeft,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchModal(BuildContext context) async {
    String searchText = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  _searchUsers(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  border: InputBorder.none,
                  suffixIcon: Icon(
                    Icons.search,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_searchResults[index].name),
                  onTap: () {
                    // Do something with the selected user
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Add user to team $team'),
                        content: SizedBox(
                          height: 100,
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                  _searchResults[index].photourl,
                                ),
                              ),
                              Text('Name: ${_searchResults[index].name}'),
                              Text('Email: ${_searchResults[index].email}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                final newUser = User(
                                  id: _searchResults[index].id,
                                  name: _searchResults[index].name,
                                  email: _searchResults[index].email,
                                  photourl: _searchResults[index].photourl,
                                );
                                bool check = true;
                                for (var x in usersA) {
                                  if (x.id == newUser.id) {
                                    check = false;
                                  }
                                }
                                for (var x in usersB) {
                                  if (x.id == newUser.id) {
                                    check = false;
                                  }
                                }
                                if (check && team == 'A') {
                                  if (usersA.length < widget.num) {
                                    usersA.add(newUser);
                                    namesA.add(newUser.name);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Slots already filled.'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                } else {
                                  if (check && team == 'B') {
                                    if (usersB.length < widget.num) {
                                      usersB.add(newUser);
                                      namesB.add(newUser.name);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Slots already filled.'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  }
                                }
                              });
                            },
                            child: Text('Add User'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
