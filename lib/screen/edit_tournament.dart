// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

class EditTournament extends StatefulWidget {
  var snap;
  EditTournament({
    super.key,
    required this.snap,
  });

  @override
  State<EditTournament> createState() => _EditTournamentState();
}

class _EditTournamentState extends State<EditTournament> {
  String team = "";
  String c = '';
  bool isFree = false;

  final TextEditingController _priceController = TextEditingController();

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
    _descController.text = widget.snap['description'];
    _locationController.text = widget.snap['location'];
    _priceController.text = widget.snap['teamsLeft'].toString();
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.first;

    setState(() => pickedFile = path);
  }

  Future uploadFile() async {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('please wait'),
          content: Text('Making in progress..'),
        );
      },
    );
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    var data = snap.data();
    String urlDownload = widget.snap['imageUrl'];

    if (data != null) {
      if (pickedFile != null) {
        final file = File(pickedFile!.path!);
        final destination = 'tournaments/${pickedFile!.name}';

        task = FirebaseApi.uploadFile(destination, file);
        setState(() {});

        final snapshot = await task!.whenComplete(() {});
        urlDownload = await snapshot.ref.getDownloadURL();
      }
      print(widget.snap['tournamentId']);
      print(((int.parse(_priceController.text) as int).runtimeType));
      print(widget.snap['maxTeam'].runtimeType);
      final maxT =
          ((int.parse(_priceController.text) as int) - widget.snap['maxTeam']);
      print(maxT);

      try {
        await _firestore
            .collection('tournaments')
            .doc(widget.snap['tournamentId'])
            .update({
          'imageUrl': urlDownload,
          'location': _locationController.text,
          'tournamentDateTime': _selectedValue,
          'description': _descController.text,
          'teamsLeft': int.parse(_priceController.text),
          'maxTeam': maxT,
        });
      } catch (e) {
        print(e.toString());
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                          await uploadFile();
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
                                    'Update',
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width * 0.95,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  widget.snap['imageUrl'],
                                  fit: BoxFit.cover,
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
                              // hintText: 'Say something about this match...',
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
