import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/User/UserEvents.dart';

class AddUserEvent extends StatefulWidget {
  const AddUserEvent({super.key});

  @override
  State<StatefulWidget> createState() => _AddUserEventState();
}

final user = FirebaseAuth.instance.currentUser;
DataBaseClass mydb = DataBaseClass();
final _nameController = TextEditingController();
final _dateController = TextEditingController();
final _locationController = TextEditingController();
final _descriptionController = TextEditingController();
final _statusController = TextEditingController();
final keyAdd = GlobalKey<FormState>();

class _AddUserEventState extends State<AddUserEvent> {
  @override
  void initState() {
    super.initState();
    mydb.initialize();
  }

  // Adding event to FireStore and local DB
  // Future<void> addEventToFirestore(Map<String, dynamic> eventData, int localDBID) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       // Add event to FireStore under the logged-in user's UID
  //       DocumentReference docRef = await FirebaseFirestore.instance
  //           .collection('Users')
  //           .doc(user.uid)
  //           .collection('Events')
  //           .add(eventData);
  //
  //       // Update the local database with FireStore ID
  //       String firestoreID = docRef.id;
  //       String updateQuery =
  //           "UPDATE Events SET FireStoreID = '$firestoreID' WHERE ID = $localDBID";
  //       await mydb.updateData(updateQuery);
  //     } catch (e) {
  //       print("Error adding event to Firestore: $e");
  //     }
  //   }
  // }

  // Save event locally and in Firestore
  Future<void> _saveEvent() async {
    if (keyAdd.currentState!.validate()) {
      try {
        String name = _nameController.text;
        String date = _dateController.text;
        String location = _locationController.text;
        String description = _descriptionController.text;
        String status = _statusController.text;

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return;
        }
        String userUID = user.uid;  // Get the current logged in user's UID

        // Insert event into the local database
        int localDBID = await mydb.insertData(
          '''
        INSERT INTO Events (Name, Date, Location, Description, Status, UserID)
        VALUES ("$name", "$date", "$location", "$description", "$status", "$userUID")
        ''',
        );

        // Prepare event data to be added to FireStore (Mapping between FireStore and local db)
        Map<String, dynamic> eventData = {
          'Name': name,
          'Date': date,
          'Location': location,
          'Description': description,
          'Status': status,
          'LocalDBID': localDBID,
        };

        // Add event to FireStore under the current user's UID
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userUID)
            .collection('Events')
            .add(eventData);

        // After FireStore has the event, update the local database with FireStoreID
        String firestoreID = docRef.id;
        String updateQuery = '''
        UPDATE Events SET FireStoreID = '$firestoreID' WHERE ID = $localDBID
      ''';
        await mydb.updateData(updateQuery);

        _nameController.clear();
        _dateController.clear();
        _locationController.clear();
        _descriptionController.clear();
        _statusController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserEvents()),
        );
      } catch (e) {
        print("Error saving event: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Add New Event",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: keyAdd,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Name"),
                controller: _nameController,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 3 ||
                      value.trim().length > 50) {
                    return "Please enter a valid event name (min 3 characters).";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Date (DD-MM-YYYY)"),
                controller: _dateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the event date";
                  }
                  //^(0[1-9]|[12][0-9]|3[01]): ensures that day is between 01 and 31.
                  // -(0[1-9]|1[0-2]): ensures that  month is between 01 and 12.
                  // -\d{4}$: ensures that year consists of 4-digits).
                  RegExp dateRegExp = RegExp(r'^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-\d{4}$');

                  // Check if the input matches the DD-MM-YYYY format
                  if (!dateRegExp.hasMatch(value)) {
                    return "Please enter a valid date in DD-MM-YYYY format";
                  }

                  // Split the input into day, month, and year
                  List<String> dateParts = value.split('-');
                  int day = int.parse(dateParts[0]);
                  int month = int.parse(dateParts[1]);
                  int year = int.parse(dateParts[2]);

                  // Check if the date is valid
                  try {
                    DateTime date = DateTime(year, month, day);
                    // Check if the day is valid for the given month and year
                    if (date.month == month && date.day == day) {
                      return null;  // Valid date
                    } else {
                      return "Please enter a valid date";
                    }
                  } catch (e) {
                    return "Please enter a valid date";
                  }
                },
              ),

              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Location"),
                controller: _locationController,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 3 ||
                      value.trim().length > 50) {
                    return "Please check the location";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Description"),
                controller: _descriptionController,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 3 ||
                      value.trim().length > 50) {
                    return "Please enter a valid gift name (min 3 characters).";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: "Enter the Status (Upcoming/ Current/ Past)"),
                controller: _statusController,
                validator: (value) {
                  if (value == null || value.isEmpty|| value.trim().length < 4 ||
                      value.trim().length > 8) {
                    return "Enter one of these values only (Upcoming/ Current/ Past)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _saveEvent,
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
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
