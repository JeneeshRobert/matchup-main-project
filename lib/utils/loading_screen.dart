import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: 210.0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 15.0,
            child: Container(
              height: 120.0,
              width: 200.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Text(
                      //   snap['name'],
                      //   style: const TextStyle(
                      //     fontSize: 20.0,
                      //     fontWeight: FontWeight.w500,
                      //     letterSpacing: 0.5,
                      //   ),
                      // ),
                      // Text(
                      //   snap['collegeName'].toString().substring(
                      //       0, snap['collegeName'].toString().length - 8),
                      //   style: const TextStyle(),
                      // ),
                    ]),
              ),
            ),
          ),
          Container(
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              // ignore: prefer_const_literals_to_create_immutables
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    color: Color.fromARGB(255, 223, 222, 222),
                    height: 180.0,
                    width: 180,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
