// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:turfit/.env';
import 'package:turfit/screen/announcements.dart';
import 'package:turfit/screen/bracket.dart';
import 'package:turfit/screen/home_screen.dart';
import 'package:turfit/screen/login_screen.dart';
import 'package:turfit/auth/auth_methods.dart';
import 'package:turfit/auth/user_provider.dart';
import 'package:turfit/screen/menu_screen.dart';
import 'package:turfit/screen/signout.dart';
import 'package:turfit/temp.dart';
import 'package:wiredash/wiredash.dart';

import 'screen/conducted_matches.dart';
import 'screen/group_members.dart';
import 'screen/participated_matches.dart';
import 'screen/participated_tournaments.dart';
import 'screen/personal_tournaments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey = pk;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.light,
      textTheme: GoogleFonts.latoTextTheme(),
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // remove the drop shadow
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        title: 'College Sports App',
        home: UserAuth(),
      ),
    );
  }
}

class UserAuth extends StatefulWidget {
  const UserAuth({super.key});

  @override
  State<UserAuth> createState() => _UserAuthState();
}

class _UserAuthState extends State<UserAuth> {
  MenuItem currentItem = MenuItems.homeScreen;
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.isAuthenticated) {
      print('authenticated');
    } else {
      print('not authenticated');
    }

    if (auth.isAuthenticated) {
      return Consumer<UserProvider>(builder: (context, userProvider, child) {
        if (userProvider.userModel == null) {
          // load the user data and update the provider
          final authmeth = authmethods();
          authmeth.getuserdetails().then((userModel) {
            userProvider.setUserModel(userModel);
          });
          return Scaffold(
            body: Center(
              child: LoadingAnimationWidget.flickr(
                  leftDotColor: Color(0xFFEB455F),
                  rightDotColor: Color(0xFF2B3467),
                  size: 30),
            ),
          );
        }
        userProvider = Provider.of<UserProvider>(context);
        final userModel = userProvider.userModel;

        print("userModel!.usernamexxxxxxxxxxxxxxxxxxxx");
        print(userModel!.username);
        if (userModel.mail == "admin@gmail.com") {
          return Scaffold(
            body: CreateAnnouncementPage(),
          );
        }
        return Scaffold(
          backgroundColor: Colors.green[300],
          body: ZoomDrawer(
            borderRadius: 40,
            showShadow: true,
            mainScreen: getScreen(),
            menuScreen: Builder(builder: (context) {
              return MenuScreen(
                  currentItem: currentItem,
                  onSelectedItem: (item) {
                    setState(() {
                      currentItem = item;
                    });

                    ZoomDrawer.of(context)!.close();
                  });
            }),
            slideWidth: MediaQuery.of(context).size.width * 0.6,
          ),
        );
      });
    } else {
      return loginscreen();
    }
  }

  Widget getScreen() {
    switch (currentItem) {
      case MenuItems.homeScreen:
        return HomeScreen();
      case MenuItems.hTournaments:
        return PersonalTournamentsScreen();
      case MenuItems.pTournaments:
        return PersonalPTournamentsScreen();
      case MenuItems.pMatches:
        return PMatches();
      case MenuItems.hMatches:
        return CMatches();
      default:
        return SignOut();
    }
  }
}
