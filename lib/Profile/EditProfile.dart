import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final keyProfile = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> _updateUserProfile() async {
    try {
      if (_displayNameController.text.isNotEmpty) {
        await user?.updateDisplayName(_displayNameController.text);
      }
      if (_photoUrlController.text.isNotEmpty) {
        await user?.updatePhotoURL(_photoUrlController.text);
      }

      await FirebaseAuth.instance.currentUser?.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      _displayNameController.clear();
      _photoUrlController.clear();
    } catch (error) {
      // Show an error message if the update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Update Profile',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: keyProfile,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                        hintText: "Enter the new username"),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 3 ||
                          value.trim().length > 50) {
                        return ("Check the name please");
                      }
                      return null;
                    },
                    controller: _displayNameController,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                        hintText: "Enter the new profile URL"),
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
                    controller: _photoUrlController,
                  ),
                  const SizedBox(height: 20),
                  Animate(
                    effects: [
                      SlideEffect(
                        begin: Offset(2, 0),
                        end: Offset.zero,
                        duration: 700.ms,
                        curve: Curves.easeInOut,
                      ),
                    ],
                    child: ElevatedButton(
                      onPressed: () async {
                        if (keyProfile.currentState!.validate()) {
                          await _updateUserProfile();
                          Navigator.pop(context);
                        }
                      },
                      style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Update Profile',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )),
        ));
  }
}
