import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hedieaty_project/Authentication/AuthUser.dart';
import 'package:hedieaty_project/OnBoarding/Login.dart';

import '../Friends/FriendsList.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();
  final myAuth = AuthUser();
  bool _displayPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.lightBlue.shade700,
              Colors.lightBlue.shade500,
              Colors.lightBlue.shade300,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text("Create account",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 33,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: Row(
                        children: [
                          const Text("Already a member? ",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                  (route) => false);
                            },
                            child: const Text("Sign in",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 60),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Form(
                          key: _formKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromRGBO(173, 216, 230, 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200)),
                                  ),
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.person),
                                      hintText: "Username",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200)),
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.mail),
                                      hintText: "Email",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      final emailRegex = RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200)),
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_displayPassword,
                                    decoration: InputDecoration(
                                      icon: const Icon(Icons.lock),
                                      hintText: "Password",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _displayPassword =
                                                !_displayPassword;
                                          });
                                        },
                                        icon: Icon(
                                          _displayPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200)),
                                  ),
                                  child: TextFormField(
                                    controller: _profilePicController,
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.image),
                                      hintText: "Profile URL",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Enter the profile pic please";
                                      }
                                      // Check if the entered value is a valid URL
                                      Uri? uri = Uri.tryParse(value);
                                      if (uri == null || !uri.hasAbsolutePath) {
                                        return "Enter a valid URL for the profile pic";
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: MaterialButton(
                          onPressed: () async {
                            bool status = await myAuth.sign_up(
                              _emailController.text,
                              _passwordController.text,
                              _nameController.text,
                              _profilePicController.text,
                            );
                            if (status) {
                              await myAuth.saveUserData(
                                  _nameController.text, _emailController.text);
                              Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return HomePage();
                                  },
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var scaleTween = Tween(begin: 0.0, end: 1.0)
                                        .chain(CurveTween(
                                            curve: Curves.easeInOut));
                                    var scaleAnimation =
                                        animation.drive(scaleTween);
                                    return ScaleTransition(
                                        scale: scaleAnimation, child: child);
                                  },
                                  transitionDuration:
                                      Duration(milliseconds: 700),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                animType: AnimType.rightSlide,
                                title: 'Credential Problem',
                                desc:
                                    'Password is weak or email is already in use.',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {},
                                customHeader: const Icon(Icons.error,
                                    size: 100, color: Colors.red),
                              ).show();
                            }
                          },
                          height: 50,
                          color: Colors.lightBlue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text("Sign up",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1700),
                        child: const Text("Or Continue with:",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: FadeInUp(
                              duration: const Duration(milliseconds: 1900),
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon:
                                    Icon(Icons.g_mobiledata_outlined, size: 25),
                                // Increase icon size
                                label: const Text('Google',
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold)),
                                // Increase text size
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 15), // Increase padding
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
