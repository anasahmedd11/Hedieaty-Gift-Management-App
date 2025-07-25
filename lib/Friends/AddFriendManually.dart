import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Friends/FriendsList.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  State<AddFriend> createState() => _AddState();
}

class _AddState extends State<AddFriend> {
  DataBaseClass mydb = DataBaseClass();
  final GlobalKey<FormState> Mykey = GlobalKey<FormState>();
  TextEditingController Name = TextEditingController();
  TextEditingController ProfilePic = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController PhoneNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    mydb.initialize();
  }

  Future<void> addFriendToFirestore(Map<String, dynamic> friendData, int localDBID) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Friends')
            .add(friendData);

        String firestoreID = docRef.id;
        String updateQuery =
            "UPDATE Users SET FireStoreID = '$firestoreID' WHERE ID = $localDBID";
        await mydb.updateData(updateQuery);
      } catch (e) {
        print("Error adding friend to Firestore: $e");
      }
    }
  }

  Future<void> saveUser() async {
    if (Mykey.currentState!.validate()) {
      try {
        String name = Name.text;
        String email = Email.text;
        String profilePic = ProfilePic.text;
        String phoneNumber = PhoneNumber.text;

        // Get the currently logged-in user's UID
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("No user logged in");

        String loggedInUserID = user.uid;

        int localDBID = await mydb.insertData(
            '''
        INSERT INTO Users (Name, Email, ProfilePic, PhoneNumber, LinkedUserID) 
        VALUES ("$name", "$email", "$profilePic", "$phoneNumber", "$loggedInUserID")
        '''
        );

        await addFriendToFirestore(
          {
            'Name': name,
            'Email': email,
            'ProfilePic': profilePic,
            'PhoneNumber': phoneNumber,
            'LocalDBID': localDBID,
          },
          localDBID,
        );

        Navigator.pushReplacement(context,  PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return HomePage();
          },
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            var scaleTween = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut));
            var scaleAnimation = animation.drive(scaleTween);
            return ScaleTransition(
                scale: scaleAnimation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),);
      } catch (e) {
        print("Error saving user: $e");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title:  FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: const Text(
            "Add New Friend",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: Mykey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  key: ValueKey('addFriendManuallyNameTextFormField'),
                  decoration: const InputDecoration(hintText: "Enter the Name"),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length > 50) {
                      return "Please enter a valid name (max 50 characters).";
                    }
                    return null;
                  },
                  controller: Name,
                ),
                TextFormField(
                  key: ValueKey('addFriendManuallyPhoneTextFormField'),
                  decoration: const InputDecoration(hintText: "Enter the Phone Number"),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length!= 12) {
                      return "Please enter a valid phone number (e.g., 201012345678)";
                    }
                    return null;
                  },
                  controller: PhoneNumber,
                ),
                TextFormField(
                  key: ValueKey('addFriendManuallyEmailTextFormField'),
                  decoration: const InputDecoration(hintText: "Enter the Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Email must include an "@" symbol and a domain name.';
                    }
                    return null;
                  },
                  controller: Email,
                ),
                TextFormField(
                  key: ValueKey('addFriendManuallyProfilePicTextFormField'),
                  decoration: const InputDecoration(hintText: "Enter the Profile Pic"),
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
                  controller: ProfilePic,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      key: ValueKey('addFriendManuallySubmitButton'),
                      onPressed: saveUser,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
