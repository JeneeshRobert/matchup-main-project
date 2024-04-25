// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turfit/screen/tournament_details_screen.dart';

class MySlider extends StatefulWidget {
  const MySlider({Key? key}) : super(key: key);

  @override
  State<MySlider> createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Stream<QuerySnapshot>? _eventsStream;

  Future<List<QueryDocumentSnapshot>> fetchMatchesWithLeastSeatsLeft() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .orderBy('seatsLeft')
        .limit(4)
        .get();

    return querySnapshot.docs;
  }

  @override
  void initState() {
    super.initState();
    _eventsStream = _db
        .collection('tournaments')
        .orderBy(FieldPath.documentId)
        .limit(3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
          stream: _eventsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // Show a loading indicator while waiting for data
            }
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            List<QueryDocumentSnapshot> carouselDocuments = [];
            carouselDocuments = documents;

            return CarouselSlider(
              options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.8),
              items: documents
                  .map((document) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => TournamentDetailsPage(
                                    snap: document,
                                  )));
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              top: 10,
                              child: ClipPath(
                                clipper: CustomClipperBGRectangle(),
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(12),
                                  strokeWidth: 0.5,
                                  borderPadding: EdgeInsets.all(10),
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    height: 150,
                                    width: 300,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 28.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          FaIcon(FontAwesomeIcons.basketball),
                                          Text(
                                            "${document['maxTeam']} teams left",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 15,
                              child: ClipPath(
                                clipper: CustomClipperRectangle(),
                                child: Container(
                                  width: 180,
                                  height: 130,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                        Color(0xFFf65a8a),
                                        Color(0xFFf16172)
                                      ])),
                                  child: Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 28.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text('₹ 2499'),
                                          Text(
                                            document['name'],
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              // [
              //   ListView.builder(
              //     itemCount: 2,
              //     itemBuilder: (BuildContext context, int index) {
              //       final matchSnapshot =
              //           matches[index].data() as Map<String, dynamic>;
              //       return
              //     },
              //   ),
              // ],
            );
          }),
    );
    // StreamBuilder<QuerySnapshot>(
    //   stream: _eventsStream,
    //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //     if (snapshot.hasError) {
    //       return Text('Error: ${snapshot.error}');
    //     }

    //     switch (snapshot.connectionState) {
    //       case ConnectionState.waiting:
    //         return Text('Loading...');
    //       default:
    //         List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
    //         List<QueryDocumentSnapshot> carouselDocuments = [];
    //         if (documents.length == 1) {
    //           carouselDocuments.addAll(documents);
    //           carouselDocuments.addAll(documents);
    //           carouselDocuments.addAll(documents);
    //         } else if (documents.length == 2) {
    //           carouselDocuments.addAll(documents);
    //           carouselDocuments.addAll(documents);
    //         } else if (documents.length > 3) {
    //           documents.shuffle();
    //           carouselDocuments = documents.sublist(0, 3);
    //         } else {
    //           carouselDocuments = documents;
    //         }

    //         return CarouselSlider(
    //           options: CarouselOptions(
    //               height: 180.0,
    //               enlargeCenterPage: true,
    //               autoPlay: true,
    //               aspectRatio: 16 / 9,
    //               autoPlayCurve: Curves.fastOutSlowIn,
    //               enableInfiniteScroll: true,
    //               autoPlayAnimationDuration: Duration(milliseconds: 800),
    //               viewportFraction: 0.8),
    //           items: documents
    //               .map((document) => Container(
    //                     decoration: BoxDecoration(
    //                       borderRadius: BorderRadius.circular(10.0),
    //                       image: DecorationImage(
    //                         image: NetworkImage(document['posterUrl']),
    //                         fit: BoxFit.cover,
    //                       ),
    //                     ),
    //                   ))
    //               .toList(),
    //         );
    //     }
    //   },
    // );
  }
}

class CustomClipperRectangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 24.0; // Radius of curved corners
    final Path path = Path();

    // Move to top left corner
    path.moveTo(0.0, 0.0);

    // Draw top right curved corner
    path.lineTo(size.width - radius, 0.0);
    path.quadraticBezierTo(
        size.width, 0.0, size.width - 10, radius); // Top right curve

    // Draw bottom right corner
    path.lineTo(size.width - 50, size.height - radius);
    path.quadraticBezierTo(size.width - 60, size.height,
        size.width - radius - 60, size.height); // Bottom right curve

    // Draw bottom left corner
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0.0, radius); // Bottom left curve

    // Draw top left corner
    path.quadraticBezierTo(0.0, 0.0, radius, 0.0); // Top left curve

    path.close(); // Close the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomClipperBGRectangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 24.0; // Radius of curved corners
    final Path path = Path();

    // Move to top left corner
    path.moveTo(0.0, 0.0);

    // Draw top right curved corner
    path.lineTo(size.width - radius, 0.0);
    path.quadraticBezierTo(
        size.width, 0.0, size.width, radius); // Top right curve

    // Draw bottom right corner
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius,
        size.height); // Bottom right curve

    // Draw bottom left corner
    path.lineTo(size.width / 2, size.height - 8);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0.0, radius); // Bottom left curve

    // Draw top left corner
    path.quadraticBezierTo(0.0, 0.0, radius, 0.0); // Top left curve

    path.close(); // Close the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
