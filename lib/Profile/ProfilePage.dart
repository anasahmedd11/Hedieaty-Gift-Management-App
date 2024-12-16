import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hedieaty_project/Profile/EditProfile.dart';
import 'package:hedieaty_project/User/UserEvents.dart';

import '../Models/Gift.dart';
import '../User/PledgedGiftsTemporary.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  List<Gift> pledgedGifts = [];

  @override
  void initState() {
    super.initState();
    _reloadUser();
  }

  void _reloadUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

 

  void _navigateToEditProfile() async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return UpdateProfilePage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Customize duration
          var tween = Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut));
          var scaleAnimation = animation.drive(tween);

          return ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
    _reloadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${user!.displayName!} \'s Profile',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Animate(
            effects: [
              SlideEffect(
                begin: Offset(2, 2), // first value represents x, second represents y
                end: Offset.zero,    // Slide to the original position
                duration: 800.ms,
                curve: Curves.easeInOut,
              ),
            ],
            child: Card(
              elevation: 5,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    user?.photoURL != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(user!.photoURL!),
                          )
                        : const Icon(Icons.account_circle, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      user?.email ?? 'No email available',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.displayName ?? 'No display name available',
                      style: const TextStyle(fontSize: 19),
                    ),
                    const SizedBox(height: 10),
                    Animate(
                      effects: [
                        SlideEffect(
                          begin: Offset(2, 0),
                          end: Offset.zero,
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        ),
                      ],
                      child: ElevatedButton(
                        onPressed: _navigateToEditProfile,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return UserEvents();
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var offsetTween =
                        Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
                    var offsetAnimation = animation.drive(offsetTween);
                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                  transitionDuration: Duration(milliseconds: 500),
                ),
              );
            },
            child: Animate(
              effects: [
                SlideEffect(
                  begin: Offset(2, 2), // first value represents x, second represents y
                  end: Offset.zero,    // Slide to the original position
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                ),
              ],
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Created Events',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Animate(effects: [
                        SlideEffect(
                          begin: Offset(2, 2),
                          // first value represents x, second represents y
                          end: Offset.zero,
                          // Slide to the original position
                          duration: 900.ms,
                          curve: Curves.easeInOut,
                        ),
                      ], child: Icon(Icons.arrow_forward)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PledgedGiftsTempPage(),));
            },
            child: Animate(
              effects: [
                SlideEffect(
                  begin: Offset(2, 2), // first value represents x, second represents y
                  end: Offset.zero,    // Slide to the original position
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                ),
              ],
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Pledged Gifts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
