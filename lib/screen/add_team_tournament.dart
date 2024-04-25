// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:ffi';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:turfit/utils/am_pm.dart';
import 'package:turfit/utils/hours.dart';
import 'package:turfit/utils/minutes.dart';
import 'package:uuid/uuid.dart';
import 'package:turfit/.env';

import 'package:http/http.dart' as http;

import '../auth/user_provider.dart';

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

class AddTeamForTournament extends StatefulWidget {
  List<User> usersA = [];

  final tournamentData;
  AddTeamForTournament({
    super.key,
    this.usersA = const [],
    required this.tournamentData,
  });

  @override
  State<AddTeamForTournament> createState() => _AddTeamForTournamentState();
}

class _AddTeamForTournamentState extends State<AddTeamForTournament> {
  final TextEditingController _descController = TextEditingController();
  Map<String, dynamic>? paymentIntent;

  List<User> usersA = [];
  List<User> usersB = [];

  List<String> namesA = [];
  List<String> namesB = [];
  String team = "";
  List<User> _users = [];
  List<User> _searchResults = [];
  bool _isLoading = true;
  DateTime _selectedValue = DateTime.now();
  late FixedExtentScrollController? _controller;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _controller = FixedExtentScrollController();
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $sk',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successfull"),
                        ],
                      ),
                    ],
                  ),
                ));

        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));
        Navigator.of(context).pop();
        await addMatchData();
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  Future<bool> istournamentIdInUserMatches(String tournamentId) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final userMatches =
        await userDoc.get().then((doc) => doc.data()?['matches']);

    return userMatches != null && userMatches.contains(tournamentId);
  }

  Future<String> makePayment(String price) async {
    String res = "error";
    try {
      paymentIntent = await createPaymentIntent(price, 'INR');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Travel Gram'))
          .then((value) {});

      ///now finally display payment sheeet
      await displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
    res = "success";
    return res;
  }

  Future addMatchData() async {
    setState(() {
      _isLoading = true;
    });
    String teamId = const Uuid().v1();
    if (_descController.text.isNotEmpty) {
      if (usersA.length == widget.tournamentData['seats']) {
        FocusScope.of(context).unfocus();

        CollectionReference matchesCollection = FirebaseFirestore.instance
            .collection('tournaments')
            .doc(widget.tournamentData['tournamentId'])
            .collection('players');

        DocumentReference newMatchDoc = matchesCollection.doc(teamId);

        await newMatchDoc.set({
          'teamName': _descController.text,
          'teamId': teamId,
          'players': [],
          'points': 0,
        });

        DocumentReference playerADoc = FirebaseFirestore.instance
            .collection('tournaments')
            .doc(widget.tournamentData['tournamentId'])
            .collection('players')
            .doc(teamId);
        for (var player in usersA) {
          print(player.toJson());
          try {
            await FirebaseFirestore.instance
                .collection("tournaments")
                .doc(widget.tournamentData['tournamentId'])
                .collection('players')
                .doc(teamId)
                .update(
              {
                "players": FieldValue.arrayUnion(
                  [player.toJson()],
                ),
              },
            );
          } catch (e) {
            e.toString();
          }
        }
        try {
          await FirebaseFirestore.instance
              .collection("tournaments")
              .doc(widget.tournamentData['tournamentId'])
              .update(
            {
              "maxTeam": FieldValue.increment(
                -1,
              ),
            },
          );
        } catch (e) {
          e.toString();
        }
        for (var player in usersA) {
          try {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(player.id)
                .update(
              {
                "participatedTournaments": [
                  widget.tournamentData['tournamentId']
                ]
              },
            );
          } catch (e) {
            e.toString();
          }
        }

        try {
          DocumentReference playerRef = FirebaseFirestore.instance
              .collection('tournaments')
              .doc(widget.tournamentData['tournamentId'])
              .collection('players')
              .doc('temp');

          DocumentSnapshot playerSnapshot = await playerRef.get();

          if (playerSnapshot.exists) {
            await playerRef.delete();
            print('Player document deleted successfully');
          } else {
            print('Player document does not exist');
          }
        } catch (e) {
          print('Error deleting player document: $e');
        }
        Navigator.pop(context);
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Provide ${widget.tournamentData["seats"]} players'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Provide team name'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    setState(() {
      _isLoading = true;
    });
  }

  Future<void> _fetchUsers() async {
    // Fetch users from Firebase
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Convert fetched data to User objects
    List<User> users = snapshot.docs
        .map((doc) => User(
              id: doc.id,
              name: (doc.data() as Map<String, dynamic>)['username'],
              email: (doc.data() as Map<String, dynamic>)['email'],
              photourl: (doc.data() as Map<String, dynamic>)['photourl'],
            )) // Cast to Map<String, dynamic>
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
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;

    final fontSize = MediaQuery.of(context).size.width;
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
                        onTap: () async {
                          if (widget.tournamentData['maxTeams'] == 0) {
                            final snackBar = SnackBar(
                              /// need to set following properties for best effect of awesome_snackbar_content
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'sorry',
                                message: 'Joining has already closed.',

                                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                contentType: ContentType.success,
                              ),
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(snackBar);
                          } else {
                            await addMatchData();
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
                                    'Joined Game. Go to participated tournaments for more details.',

                                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                contentType: ContentType.success,
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
                                    Color.fromARGB(255, 98, 157, 100),
                                    Color(0xFF81C784),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: userModel!.mail != 'admin@gmail.com'
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Center(
                                          child: _isLoading
                                              ? LoadingAnimationWidget.flickr(
                                                  leftDotColor:
                                                      Color(0xFFEB455F),
                                                  rightDotColor:
                                                      Color(0xFF2B3467),
                                                  size: 25)
                                              : Text(
                                                  'Add your Team',
                                                  style: TextStyle(
                                                    fontSize: fontSize * 0.03,
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                  ),
                                                )),
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Team'),
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
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          '${usersA.length} / ${widget.tournamentData["seats"]}'),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 10,
                      ),
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
                        Container(
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
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Team Name',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: fontSize * 0.06,
                        ),
                        ClipRRect(
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
                                        'Team (${namesA.length})',
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
                        SizedBox(
                          height: fontSize * 0.06,
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
                  suffixIcon: Icon(Icons.search),
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

                                if (check &&
                                    usersA.length <
                                        widget.tournamentData['seats']) {
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
