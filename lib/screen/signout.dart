import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfit/auth/auth_methods.dart';
import 'package:turfit/screen/login_screen.dart';

class SignOut extends StatefulWidget {
  const SignOut({super.key});

  @override
  State<SignOut> createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    await auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => loginscreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
