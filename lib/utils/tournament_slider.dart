// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turfit/screen/details_screen.dart';
import 'package:turfit/screen/tournament_details_screen.dart';
import 'package:turfit/utils/dynamic_icon.dart';
import 'package:turfit/utils/homepage_dynamic_list.dart';
import 'package:turfit/utils/loading_screen.dart';

// class TournamentSlider extends StatelessWidget {
//   TournamentSlider({Key? key}) : super(key: key);

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<String> docIDs = [];

//   Future getdocIDs() async {
//     await _firestore
//         .collection('tournaments')
//         // .orderBy('age', descending: false)
//         .get()
//         .then((snapshot) => snapshot.docs.forEach((document) {
//               docIDs.add(document.reference.id);
//             }));
//   }

//   final List<ColorPair> colorPairs = [
//     ColorPair(color1: Color(0xFFa091fb), color2: Color(0xFFc895fa)),
//     ColorPair(color1: Color(0xFF40aa84), color2: Color(0xFF8ac481)),
//     ColorPair(color1: Color(0xFFf48a80), color2: Color(0xFFf9ab77)),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Tournaments 🏟️",
//                     style: TextStyle(
//                         fontSize: 16.0,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.4),
//                   ),
//                   GestureDetector(
//                     child: const Text(
//                       "...",
//                       style: TextStyle(
//                           fontSize: 30.0,
//                           fontWeight: FontWeight.w400,
//                           color: Color.fromARGB(255, 24, 150, 209),
//                           letterSpacing: 0.2),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             FutureBuilder<QuerySnapshot>(
//               future:
//                   FirebaseFirestore.instance.collection('tournaments').get(),
//               builder: ((context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return SizedBox(
//                     height: 300,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: 3,
//                       itemBuilder: (BuildContext context, int index) {
//                         return LoadingScreen();
//                       },
//                     ),
//                   );
//                 }
//                 return SizedBox(
//                   height: 200,
//                   width: double.infinity,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       final document = snapshot.data!.docs[index].data()
//                           as Map<String, dynamic>;

//                       final random = Random();
//                       final colorPair =
//                           colorPairs[random.nextInt(colorPairs.length)];

//                       final gradient = LinearGradient(
//                         colors: [colorPair.color1, colorPair.color2],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       );

//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => TournamentDetailsPage(
//                                 snap: document,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: 170,
//                           margin: EdgeInsets.only(left: 20),
//                           decoration: BoxDecoration(
//                             gradient: gradient,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 15),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Chip(
//                                       backgroundColor:
//                                           colorPair.color1.withOpacity(0.8),
//                                       label: Text(document['name']),
//                                     ),
//                                     Container(
//                                       margin: EdgeInsets.all(5),
//                                       height: 20.0,
//                                       width: 20.0,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Container(
//                                         width: 15,
//                                         height: 15,
//                                         margin: EdgeInsets.all(3),
//                                         child: CircleAvatar(
//                                           backgroundColor:
//                                               document['maxTeam'] == 0
//                                                   ? Colors.red
//                                                   : Colors.greenAccent,
//                                         ),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.04,
//                                 ),
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       CupertinoIcons.sportscourt,
//                                       size: 40,
//                                     ),
//                                     document['maxTeam'] == 0
//                                         ? Text(
//                                             'closed',
//                                             style: TextStyle(
//                                               fontSize: 15,
//                                             ),
//                                           )
//                                         : Column(
//                                             children: [
//                                               SizedBox(
//                                                 height: 10,
//                                               ),
//                                               Text(
//                                                   "${document['maxTeam']} Teams left"),
//                                             ],
//                                           ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

class TournamentSlider extends StatelessWidget {
  TournamentSlider({Key? key}) : super(key: key);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<ColorPair> colorPairs = [
    ColorPair(color1: Color(0xFFa091fb), color2: Color(0xFFc895fa)),
    ColorPair(color1: Color(0xFF40aa84), color2: Color(0xFF8ac481)),
    ColorPair(color1: Color(0xFFf48a80), color2: Color(0xFFf9ab77)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tournaments 🏟️",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4),
                  ),
                  GestureDetector(
                    child: const Text(
                      "...",
                      style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 24, 150, 209),
                          letterSpacing: 0.2),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tournaments')
                  .snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (BuildContext context, int index) {
                        return LoadingScreen();
                      },
                    ),
                  );
                }
                return SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final document = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      final random = Random();
                      final colorPair =
                          colorPairs[random.nextInt(colorPairs.length)];

                      final gradient = LinearGradient(
                        colors: [colorPair.color1, colorPair.color2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TournamentDetailsPage(
                                snap: document,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 170,
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                      backgroundColor:
                                          colorPair.color1.withOpacity(0.8),
                                      label: Text(document['name']),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      height: 20.0,
                                      width: 20.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        width: 15,
                                        height: 15,
                                        margin: EdgeInsets.all(3),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              document['maxTeam'] == 0
                                                  ? Colors.red
                                                  : Colors.greenAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.sportscourt,
                                      size: 40,
                                    ),
                                    document['maxTeam'] == 0
                                        ? Text(
                                            'closed',
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                  "${document['maxTeam']} Teams left"),
                                            ],
                                          ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}
