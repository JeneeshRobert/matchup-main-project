// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;

  const MenuItem(this.title, this.icon);
}

class MenuItems {
  static const homeScreen = MenuItem('Home Screen', CupertinoIcons.home);
  static const hTournaments =
      MenuItem('Hosted Tournaments', CupertinoIcons.sportscourt);
  static const pTournaments =
      MenuItem('Participated Tournaments', CupertinoIcons.sportscourt);
  static const hMatches =
      MenuItem('Hosted Matches', Icons.sports_baseball_rounded);
  static const pMatches =
      MenuItem('Participated Matches', Icons.sports_baseball_rounded);
  static const Logout = MenuItem('Logout', Icons.lock);

  static const all = <MenuItem>[
    homeScreen,
    hTournaments,
    pTournaments,
    hMatches,
    pMatches,
    Logout,
  ];
}

class MenuScreen extends StatelessWidget {
  final MenuItem currentItem;
  final ValueChanged<MenuItem> onSelectedItem;
  const MenuScreen(
      {super.key, required this.currentItem, required this.onSelectedItem});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.green[300],
        body: SafeArea(
          child: Column(
            children: [
              Spacer(),
              ...MenuItems.all.map(buildMenuItem).toList(),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(MenuItem item) => ListTileTheme(
        selectedColor: Color.fromARGB(255, 64, 71, 64),
        child: ListTile(
          selectedTileColor: Color.fromARGB(255, 98, 157, 100),
          selected: currentItem == item,
          minLeadingWidth: 20,
          leading: Icon(item.icon),
          title: Text(item.title),
          onTap: () => onSelectedItem(item),
        ),
      );
}
