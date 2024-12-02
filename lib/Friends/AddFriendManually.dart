import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddState();
}

class _AddState extends State<AddUserScreen> {
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
        // Add the friend to the logged-in user's Firestore collection
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Friends')
            .add(friendData);

        // Update the local database with the Firestore ID
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

        // Insert into the local database with LinkedUserID
        int localDBID = await mydb.insertData(
            '''
        INSERT INTO Users (Name, Email, ProfilePic, PhoneNumber, LinkedUserID) 
        VALUES ("$name", "$email", "$profilePic", "$phoneNumber", "$loggedInUserID")
        '''
        );

        // Add to Firestore as before
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

        Navigator.pushNamedAndRemoveUntil(context, '/Home', (route) => false);
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
        title: const Text(
          "Add New Friend",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: Mykey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Name"),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 3 ||
                      value.trim().length > 50) {
                    return "Check the name please";
                  }
                  return null;
                },
                controller: Name,
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Phone Number"),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 10) {
                    return "Please enter a valid phone number";
                  }
                  return null;
                },
                controller: PhoneNumber,
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex =
                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                controller: Email,
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Profile Pic"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter the profile pic please";
                  }
                  return null;
                },
                controller: ProfilePic,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
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
    );
  }
}
