// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:turfit/auth/user_provider.dart';
import 'package:turfit/screen/add_game.dart';
import 'package:turfit/screen/add_tournament.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  final bool GoT;

  const OnboardingScreen({
    super.key,
    required this.GoT,
  });
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Map<String, int> sportsGamesList = {
    'Football': 11,
    'Football 5s': 5,
    'Football 7s': 7,
    'Basketball': 5,
    'Baseball': 9,
    'Tennis': 2,
    'Cricket': 11,
    'Volleyball': 6,
    'Table tennis': 2,
    'Badminton': 2,
    'Swimming': 1,
    'Cycling': 1,
    'Field hockey': 11,
    'Handball': 7,
    'Synchronized swimming': 1,
    'Diving': 1,
    'Fishing': 1,
  };

  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your Game.',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Wrap(
                  spacing: 10.0,
                  children: sportsGamesList.keys
                      .map((game) => _buildChip(game))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String game) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;
    return GestureDetector(
      onTap: () {
        print("userModel!.college");
        print(userModel!.college);
        print("userModel!.college");
        widget.GoT
            ? Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddGame(
                    sport: game,
                    num: sportsGamesList[game]!,
                    college: userModel!.college,
                  ),
                ),
              )
            : Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddTournament(
                    sport: game,
                    college: userModel!.college,
                    num: sportsGamesList[game]!,
                  ),
                ),
              );
      },
      child: Chip(
        label: Text(game),
        backgroundColor: Colors.green[300],
        labelStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
