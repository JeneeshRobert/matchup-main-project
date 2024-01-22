// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:turfit/auth/auth_methods.dart';
import 'package:turfit/main.dart';
import 'package:turfit/screen/home_screen.dart';
import 'package:turfit/screen/signup_screen.dart';
import 'package:turfit/utils/utils.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  bool _isloading = false;
  void navigatetosingnup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const signupscreen(),
      ),
    );
  }

  void loginUser() async {
    setState(() {
      _isloading = true;
    });
    String results = await authmethods().loginuser(
      email: _email.text,
      password: _pass.text,
    );
    if (results == 'success') {
      print('logging in');
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));
    } else {
      showSnakBar(results, context);
    }
    setState(() {
      _isloading = false;
    });
  }

  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            children: [
              Image(
                image: AssetImage('assets/football.gif'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'email',
                        border: InputBorder.none,
                      ),
                      controller: _email,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'password',
                        border: InputBorder.none,
                      ),
                      controller: _pass,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: loginUser,
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          color: Color(0xFF81C784),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        child: _isloading
                            ? Center(
                                child: LoadingAnimationWidget.flickr(
                                    leftDotColor: Color(0xFFEB455F),
                                    rightDotColor: Color(0xFF2B3467),
                                    size: 30),
                              )
                            : const Text('Log in'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text('Dont have an account?  '),
                        ),
                        GestureDetector(
                          onTap: navigatetosingnup,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              'Signup',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
