import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddState();
}

DataBaseClass mydb = DataBaseClass();

final GlobalKey<FormState> Mykey = GlobalKey<FormState>();
TextEditingController Name = TextEditingController();
TextEditingController ProfilePic = TextEditingController();
TextEditingController Email = TextEditingController();
TextEditingController PhoneNumber = TextEditingController();

class _AddState extends State<AddUserScreen> {
  @override
  void initState() {
    super.initState();
    DataBaseClass mydb = DataBaseClass();
    mydb.initialize();
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
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: Mykey,
              child: Column(
                children: [
                  TextFormField(
                    decoration:
                    const InputDecoration(hintText: "Enter the Name"),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 3 ||
                          value.trim().length > 50) {
                        return ("Check the name please");
                      }
                      return null;
                    },
                    controller: Name,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        hintText: "Enter the Phone Number"),
                    validator: (value) {
                      if (value == null || value.isEmpty || int.parse(value) < 14) {
                        return ("Please enter a valid phone number");
                      }
                      return null;
                    },
                    controller: PhoneNumber,
                  ),
                  TextFormField(
                    decoration:
                    const InputDecoration(hintText: "Enter the Email"),
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
                    decoration: const InputDecoration(
                        hintText: "Enter the Profile Pic"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return ("Enter the profile pic please");
                      }
                      return null;
                    },
                    controller: ProfilePic,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (Mykey.currentState!.validate()) {
                            try {
                              int response = await mydb.insertData(
                                  '''INSERT INTO Users (Name, Email, ProfilePic, PhoneNumber) 
             VALUES ("${Name.text}", "${Email.text}", "${ProfilePic.text}", "${PhoneNumber.text}")''');

                              if (response > 0) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/Home',
                                      (route) => false,
                                );
                                Name.clear();
                                Email.clear();
                                ProfilePic.clear();
                                PhoneNumber.clear();
                              } else {
                                print("Insert failed");
                              }
                            } catch (e) {
                              print("Error inserting data: $e");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ));
  }
}
