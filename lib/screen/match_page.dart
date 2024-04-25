// import 'package:flutter/material.dart';

// class MatchPage extends StatefulWidget {
//   const MatchPage({super.key});

//   @override
//   State<MatchPage> createState() => _MatchPageState();
// }

// class _MatchPageState extends State<MatchPage> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//               child: Stack(
//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.height,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [Color(0xFF009bdd), Color(0xFF02dac1)],
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: MediaQuery.of(context).size.height * 0.3,
//                     child: Container(
//                       height: MediaQuery.of(context).size.height * 0.7,
//                       width: MediaQuery.of(context).size.width,
//                       decoration: BoxDecoration(
//                         color: Color(0xFF181920),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(60),
//                           topRight: Radius.circular(60),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.only(
//                           left: fontSize * 0.06,
//                           right: fontSize * 0.06,
//                           top: fontSize * 0.35,
//                         ),
//                         child: SingleChildScrollView(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(
//                                 height: 200,
//                                 child: Column(
//                                   children: [
//                                     Expanded(
//                                       child: StreamBuilder<QuerySnapshot>(
//                                         stream: FirebaseFirestore.instance
//                                             .collection('matches')
//                                             .doc(widget.snap['matchID'])
//                                             .collection('players')
//                                             .snapshots(),
//                                         builder: (BuildContext context,
//                                             AsyncSnapshot<QuerySnapshot>
//                                                 snapshot) {
//                                           if (snapshot.hasError) {
//                                             return Text(
//                                                 'Error: ${snapshot.error}');
//                                           }
//                                           switch (snapshot.connectionState) {
//                                             case ConnectionState.waiting:
//                                               return Text('Loading...');
//                                             default:
//                                               final players =
//                                                   snapshot.data!.docs;
//                                               return ListView.builder(
//                                                 shrinkWrap: true,
//                                                 itemCount: players.length,
//                                                 itemBuilder:
//                                                     (BuildContext context,
//                                                         int index) {
//                                                   final playerData =
//                                                       players[index]['players']
//                                                           as List<dynamic>;
//                                                   final playerMaps = playerData;
//                                                   return ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10.0),
//                                                     child: Table(
//                                                       defaultVerticalAlignment:
//                                                           TableCellVerticalAlignment
//                                                               .middle,
//                                                       children: [
//                                                         // Table header row
//                                                         TableRow(
//                                                           children: [
//                                                             Container(
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 color: Colors
//                                                                     .grey[300],
//                                                               ),
//                                                               padding:
//                                                                   EdgeInsets
//                                                                       .all(8.0),
//                                                               child: Center(
//                                                                 child: Text(
//                                                                   'Team ${index + 1} (${playerMaps.length})',
//                                                                   style: TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),

//                                                         // Table data rows
//                                                         ...playerMaps.map(
//                                                           (name) => TableRow(
//                                                             children: [
//                                                               Container(
//                                                                 decoration: BoxDecoration(
//                                                                     color: Colors
//                                                                             .grey[
//                                                                         100]),
//                                                                 padding:
//                                                                     EdgeInsets
//                                                                         .all(
//                                                                             8.0),
//                                                                 child: Center(
//                                                                   child: Text(name[
//                                                                           'name']
//                                                                       .toString()),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 },
//                                               );
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                     // SizedBox(
//                                     //   height: fontSize * 0.06,
//                                     // ),
//                                     SizedBox(
//                                       height: fontSize * 0.06,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Description',
//                                     style: TextStyle(
//                                       fontSize: fontSize * 0.035,
//                                       color: Colors.white.withOpacity(0.8),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: fontSize * 0.03,
//                                   ),
//                                   Text(
//                                     "Simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
//                                     style: TextStyle(
//                                       fontSize: fontSize * 0.03,
//                                       color: Colors.white.withOpacity(0.8),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: fontSize * 0.08,
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Location',
//                                     style: TextStyle(
//                                       fontSize: fontSize * 0.035,
//                                       color: Colors.white.withOpacity(0.8),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: fontSize * 0.03,
//                                   ),
//                                   Text(
//                                     "College ground, College of Engineering Trivandrum ",
//                                     style: TextStyle(
//                                       fontSize: fontSize * 0.03,
//                                       color: Colors.white.withOpacity(0.8),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: fontSize * 0.02,
//                                   ),
//                                   Text(
//                                     "Get location ",
//                                     style: TextStyle(
//                                       fontSize: fontSize * 0.03,
//                                       color: Colors.red[300],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     left: MediaQuery.of(context).size.width * 0.05,
//                     top: MediaQuery.of(context).size.height * 0.25,
//                     child: Container(
//                       height: MediaQuery.of(context).size.height * 0.2,
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       decoration: BoxDecoration(
//                         color: Color(0xFF2b2e3b),
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(20),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               'Football',
//                               style: TextStyle(
//                                 fontSize: fontSize * 0.042,
//                                 color: Colors.white.withOpacity(0.8),
//                               ),
//                             ),
//                             SizedBox(
//                               height: fontSize * 0.03,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                               children: [
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     FaIcon(
//                                       FontAwesomeIcons.calendarDays,
//                                       color: Colors.white.withOpacity(0.8),
//                                       size: fontSize * 0.05,
//                                     ),
//                                     SizedBox(
//                                       height: fontSize * 0.02,
//                                     ),
//                                     Text(
//                                       '18-06-2032',
//                                       style: TextStyle(
//                                         fontSize: fontSize * 0.025,
//                                         color: Colors.white.withOpacity(0.8),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     FaIcon(
//                                       FontAwesomeIcons.peopleLine,
//                                       color: Colors.white.withOpacity(0.8),
//                                       size: fontSize * 0.05,
//                                     ),
//                                     SizedBox(
//                                       height: fontSize * 0.02,
//                                     ),
//                                     Text(
//                                       '20 seats',
//                                       style: TextStyle(
//                                         fontSize: fontSize * 0.025,
//                                         color: Colors.white.withOpacity(0.8),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     FaIcon(
//                                       FontAwesomeIcons.moneyBill1Wave,
//                                       color: Colors.white.withOpacity(0.8),
//                                       size: fontSize * 0.05,
//                                     ),
//                                     SizedBox(
//                                       height: fontSize * 0.02,
//                                     ),
//                                     Text(
//                                       '₹ 200',
//                                       style: TextStyle(
//                                         fontSize: fontSize * 0.025,
//                                         color: Colors.white.withOpacity(0.8),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     left: MediaQuery.of(context).size.width * 0.46,
//                     top: MediaQuery.of(context).size.height * 0.16,
//                     child: Container(
//                       height: MediaQuery.of(context).size.height * 0.2,
//                       width: MediaQuery.of(context).size.width * 0.12,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Color(0xFF2b2e3b),
//                       ),
//                       child: Center(
//                         child: FaIcon(
//                           FontAwesomeIcons.basketball,
//                           size: 35,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     left: 10,
//                     top: 10,
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Container(
//                         height: 20,
//                         width: 20,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Icon(
//                             CupertinoIcons.back,
//                             size: 20,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.height * 0.08,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(30),
//                           topRight: Radius.circular(30),
//                         ),
//                         color: Color(0xFF2b2e3b),
//                       ),
//                       child: snapshot.data == false
//                           ? Row(
//                               children: [
//                                 Expanded(
//                                     child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       addMatchData(
//                                           matchID: widget.snap['matchID'],
//                                           team: 'A',
//                                           name: userModel!.username);
//                                     },
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             Color.fromARGB(255,98, 157, 100),
//                                             Color(0xFF81C784),,
//                                           ],
//                                         ),
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Join Team A',
//                                           style: TextStyle(
//                                             fontSize: fontSize * 0.03,
//                                             color:
//                                                 Colors.white.withOpacity(0.8),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 )),
//                                 Expanded(
//                                     child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       addMatchData(
//                                           matchID: widget.snap['matchID'],
//                                           team: 'B',
//                                           name: userModel!.username);
//                                     },
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             Color.fromARGB(255,98, 157, 100),
//                                             Color(0xFF81C784),,
//                                           ],
//                                         ),
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Join Team B',
//                                           style: TextStyle(
//                                             fontSize: fontSize * 0.03,
//                                             color:
//                                                 Colors.white.withOpacity(0.8),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 )),
//                               ],
//                             )
//                           : Row(children: [
//                               Expanded(
//                                   child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     addMatchData(
//                                         matchID: widget.snap['matchID'],
//                                         team: 'A',
//                                         name: userModel!.username);
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [
//                                           Color.fromARGB(255,98, 157, 100),
//                                           Color(0xFF81C784),,
//                                         ],
//                                       ),
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         'Already Joined',
//                                         style: TextStyle(
//                                           fontSize: fontSize * 0.03,
//                                           color: Colors.white.withOpacity(0.8),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )),
//                             ]),
//                     ),
//                   ),
//                 ],
//               ),
//             );;
//   }
// }
