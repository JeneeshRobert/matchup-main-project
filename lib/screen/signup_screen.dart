// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:turfit/auth/auth_methods.dart';
import 'package:turfit/screen/home_screen.dart';
import 'package:turfit/screen/login_screen.dart';
import 'package:turfit/utils/utils.dart';

class signupscreen extends StatefulWidget {
  const signupscreen({super.key});

  @override
  State<signupscreen> createState() => _signupscreenState();
}

class _signupscreenState extends State<signupscreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  var college;
  bool _isloading = false;
  Uint8List? _image;

  List<String> colleges = [
    "Lourdes Matha College of Science and Technology Trivandrum",
    "College of science",
  ];

  void navigatetologin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const loginscreen(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _pass.dispose();
    _username.dispose();
    _phone.dispose();
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);

    setState(() {
      _image = im;
    });
  }

  void SignuUser() async {
    if (_phone.text.toString().length == 10 &&
        _image != null &&
        _username.text.isNotEmpty &&
        _email.text.isNotEmpty &&
        _pass.text.isNotEmpty) {
      print(_username.text);
      print(_username.text.isNotEmpty);
      setState(() {
        _isloading = true;
      });
      String results = await authmethods().signupuser(
        username: _username.text,
        email: _email.text,
        phone: _phone.text,
        password: _pass.text,
        file: _image!,
        college: college,
      );
      setState(() {
        _isloading = false;
      });
      if (results != 'succes') {
        showSnakBar(results, context);
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => loginscreen()));
        final snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Yay!',
            message: 'Account creation was successful',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } else {
      final snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oh Snap!',
          message: 'All fields needs to filled correctly',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: Image(
                  image: AssetImage('assets/football.gif'),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 150),
                    //Image.asset('assets/Travel-Icon-PNG-Transparent-Image.png',
                    //  height: 120),
                    //const SizedBox(height: 60),
                    Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_image!),
                              )
                            : const CircleAvatar(
                                radius: 64, backgroundColor: Colors.grey),
                        Positioned(
                          bottom: -5,
                          right: -5,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // DropdownButton<String>(
                    //   items: <String>['A', 'B', 'C', 'D'].map((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    //   onChanged: (_) {},
                    // ),

                    const SizedBox(height: 30),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'username',
                        border: InputBorder.none,
                      ),
                      controller: _username,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      decoration: InputDecoration(
                        hintText: 'email',
                        border: InputBorder.none,
                      ),
                      controller: _email,
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        disabledItemFn: (String s) => s.startsWith('I'),
                      ),
                      items: colleges,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'select college',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      onChanged: (val) {
                        college = val;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      decoration: InputDecoration(
                        hintText: 'phone',
                        border: InputBorder.none,
                      ),
                      controller: _phone,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      obscureText: true,
                      controller: _pass,
                      decoration: InputDecoration(
                        hintText: 'password',
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () {
                        SignuUser();
                      },
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
                            : const Text('Signup'),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text('Already have an account?  '),
                        ),
                        GestureDetector(
                          onTap: navigatetologin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              'login',
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
