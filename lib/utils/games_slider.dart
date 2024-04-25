// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfit/screen/search_page_matches.dart';
import 'package:turfit/utils/homepage_dynamic_list.dart';

import '../auth/user_provider.dart';

class GamesSlider extends StatelessWidget {
  const GamesSlider({Key? key}) : super(key: key);

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
                    "Games 🏏",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4),
                  ),
                  GestureDetector(
                    // onTap: () => Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => AllPage(),
                    //   ),
                    // ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => AllList()));
                      },
                      child: const Text(
                        "...",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 24, 150, 209),
                        ),
                      ),
                    ),
                    // EventsHomePageDynamic(),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            HomePageDynamicList(),
          ],
        ),
      ],
    );
  }
}
