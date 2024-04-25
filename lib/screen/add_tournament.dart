// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:turfit/utils/am_pm.dart';
import 'package:turfit/utils/hours.dart';
import 'package:turfit/utils/minutes.dart';
import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
  Map<String, dynamic> toJson() => {
        'userID': id,
        'name': name,
      };
}

class AddTournament extends StatefulWidget {
  final String sport;
  final int num;
  final String college;
  AddTournament({
    super.key,
    required this.sport,
    required this.num,
    required this.college,
  });

  @override
  State<AddTournament> createState() => _AddTournamentState();
}

class _AddTournamentState extends State<AddTournament> {
  String team = "";
  String c = '';
  bool isFree = false;

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _finalpriceController = TextEditingController();

  String p = '';
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  PlatformFile? pickedFile;
  UploadTask? task;
  File? file;
  Position? position;
  DateTime _selectedValue = DateTime.now();
  late FixedExtentScrollController? _controller;
  int hour = 12;
  int minute = 0;
  bool am = true;
  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController();
    try {
      // getUserLocation();
    } catch (e) {
      print(e.toString());
    }
  }

  bool _isLoading = false;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.first;

    setState(() => pickedFile = path);
  }

  Future<String> uploadFile() async {
    String res = 'Error';
    if (_descController.text.isNotEmpty &&
        _locationController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser!;
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      var data = snap.data();
      if (data != null) {
        final file = File(pickedFile!.path!);
        final destination = 'tournaments/${pickedFile!.name}';

        task = FirebaseApi.uploadFile(destination, file);
        setState(() {});

        final snapshot = await task!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();

        String tournamentId = const Uuid().v1();
        print(tournamentId);
        print(user.uid);
        print(urlDownload);
        print(_locationController.text);
        print(tournamentId);
        print(tournamentId);
        try {
          await _firestore.collection('tournaments').doc(tournamentId).set({
            'tournamentId': tournamentId,
            'uId': user.uid,
            'imageUrl': urlDownload,
            'location': _locationController.text,
            'college': widget.college,
            'time': DateTime.now(),
            'tournamentDateTime': _selectedValue,
            'description': _descController.text,
            'maxTeam': int.parse(_priceController.text),
            'price': int.parse(_finalpriceController.text),
            'teamsLeft': int.parse(_priceController.text),
            'name': widget.sport,
            'seats': widget.num,
            'open': true,
          }).then((value) async {
            try {
              // await _firestore
              //     .collection('tournaments')
              //     .doc(tournamentId)
              //     .collection('players')
              //     .doc('temp')
              //     .delete();
            } catch (e) {
              print(e.toString());
            }
          });
        } catch (e) {
          print(e.toString());
        }

        try {
          await _firestore.collection('users').doc(user.uid).update({
            'conductedTournaments': FieldValue.arrayUnion([tournamentId])
          });
        } catch (e) {
          print(e.toString());
        }
      }
      setState(() {
        _isLoading = false;
      });
      res = "success";
    }
    return res;
  }

  getUserLocation() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position!.latitude, position!.longitude);
    Placemark placemark = placemarks[0];
    print(placemark);
    String city = '${placemark.locality}';
    String administrativeArea = '${placemark.administrativeArea}';
    setState(() {
      c = city;
      p = administrativeArea;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    // final userModel = userProvider.userModel;

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
                          _selectedValue = _selectedValue
                              .add(Duration(hours: hour, minutes: minute));
                          if (!am) {
                            _selectedValue =
                                _selectedValue.add(Duration(hours: 12));
                          }
                          String x = await uploadFile();
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
                      if (pickedFile != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                File(
                                  pickedFile!.path!,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      if (pickedFile == null)
                        GestureDetector(
                          onTap: selectFile,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFbd91d4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.57,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
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
                          ],
                        ),
                        SizedBox(
                          height: 150,
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
                          margin: EdgeInsets.only(bottom: 20),
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
                                SizedBox(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: TextField(
                                    controller: _locationController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Location',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
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
                                SizedBox(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: TextField(
                                    controller: _priceController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Max Teams',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
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
                                SizedBox(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: TextField(
                                    controller: _finalpriceController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'fee per team',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
