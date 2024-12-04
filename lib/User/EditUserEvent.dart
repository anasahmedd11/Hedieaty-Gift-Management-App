import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_project/Models/Event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';

class EditUserEvent extends StatefulWidget {
  final Events event;
  final void Function() onEventUpdated;

  const EditUserEvent({required this.event, required this.onEventUpdated, super.key});

  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditUserEvent> {
  final _editNameController = TextEditingController();
  final _editDateController = TextEditingController();
  final _editLocationController = TextEditingController();
  final _editDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DataBaseClass _mydb = DataBaseClass();

  @override
  void initState() {
    super.initState();
    _editNameController.text = widget.event.name;
    _editDateController.text = widget.event.Date;
    _editLocationController.text = widget.event.Location;
    _editDescriptionController.text = widget.event.Description;
  }

  @override
  void dispose() {
    _editNameController.dispose();
    _editDateController.dispose();
    _editLocationController.dispose();
    _editDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _editEventData() async {
    if (_formKey.currentState!.validate()) {
      try {
        String updatedName = _editNameController.text;
        String updatedDate = _editDateController.text;
        String updatedLocation = _editLocationController.text;
        String updatedDescription = _editDescriptionController.text;

        // Check if the event exists in the local database before updating
        String selectQuery = '''
      SELECT * FROM Events WHERE FireStoreID = "${widget.event.FireStoreID}"
      ''';
        var result = await _mydb.readData(selectQuery);
        if (result.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Event not found in the local database.")),
          );
          return;
        }

        // Update local database
        String sqlQuery = '''
      UPDATE Events 
      SET Name = "$updatedName",
          Date = "$updatedDate",
          Location = "$updatedLocation",
          Description = "$updatedDescription"
      WHERE FireStoreID = "${widget.event.FireStoreID}"
      ''';
        int response = await _mydb.updateData(sqlQuery);

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .collection('Events')
                .doc(widget.event.FireStoreID)
                .update({
              'Name': updatedName,
              'Date': updatedDate,
              'Location': updatedLocation,
              'Description': updatedDescription,
            });
            print("Firestore update successful");
          } catch (error) {
            print("Error updating Firestore: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error updating FireStore: $error")),
            );
          }
        }

        if (response > 0) {
          widget.onEventUpdated(); // Refresh events list
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update the event.")),
          );
        }
      } catch (e) {
        print("Error updating event: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while updating.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _editNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().length < 3||
                      value.trim().length > 50) {
                    return 'Please enter a valid event name (min 3 characters).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Date'),
                controller: _editDateController,
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
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Location'),
                controller: _editLocationController,
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
                decoration: const InputDecoration(labelText: 'Event Description'),
                controller: _editDescriptionController,
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
                    onPressed: _editEventData,
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
