import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerCountIcon extends StatelessWidget {
  final IconData iconData;
  final DocumentReference documentReference;
  final int maxSize;

  PlayerCountIcon(
      {required this.iconData,
      required this.documentReference,
      required this.maxSize});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: documentReference.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Icon(
            iconData,
            size: 20.0,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        print("snapshot.data");
        print(snapshot.data!.data());
        final players = snapshot.data?.get('players') ?? [];
        final playerCount = players.length;
        double iconSize =
            20.0 + (playerCount.toDouble() * (maxSize.toDouble() / 10.0));

        return Icon(
          iconData,
          size: iconSize,
        );
      },
    );
  }
}
