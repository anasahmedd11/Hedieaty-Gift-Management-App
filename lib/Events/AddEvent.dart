// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:hedieaty_project/Database/DatabaseClass.dart';
// import 'package:hedieaty_project/Events/EventList.dart';
// import 'package:hedieaty_project/Models/Event.dart';
// import 'package:hedieaty_project/Models/User.dart';
//
// class NewEvent extends StatefulWidget {
//   const NewEvent({required this.friend, super.key});
//
//   final Userr friend;
//
//   @override
//   State<StatefulWidget> createState() {
//     return _NewEventState();
//   }
// }
//
// DataBaseClass mydb = DataBaseClass();
//
// final _nameController = TextEditingController();
// final _dateController = TextEditingController();
// final _locationController = TextEditingController();
// final _descriptionController = TextEditingController();
// final _statusController = TextEditingController();
// final keyAddEvent = GlobalKey<FormState>();
//
// class _NewEventState extends State<NewEvent> {
//   @override
//   void initState() {
//     super.initState();
//     DataBaseClass mydb = DataBaseClass();
//     mydb.initialize();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.blue,
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: const Text(
//             "Add New Event",
//             style: TextStyle(
//                 fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//               key: keyAddEvent,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     decoration:
//                     const InputDecoration(hintText: "Enter the Name"),
//                     validator: (value) {
//                       if (value == null ||
//                           value.isEmpty ||
//                           value.trim().length < 3 ||
//                           value.trim().length > 50) {
//                         return ("Check the name please");
//                       }
//                       return null;
//                     },
//                     controller: _nameController,
//                   ),
//                   TextFormField(
//                     decoration:
//                     const InputDecoration(hintText: "Enter the Date"),
//                     validator: (value) {
//                       if (value == null ||
//                           value.isEmpty ||
//                           value.trim().length < 3 ||
//                           value.trim().length > 50) {
//                         return ("Enter the Date please");
//                       }
//                       return null;
//                     },
//                     controller: _dateController,
//                   ),
//                   TextFormField(
//                     decoration:
//                     const InputDecoration(hintText: "Enter the Location"),
//                     validator: (value) {
//                       if (value == null ||
//                           value.isEmpty ||
//                           value.trim().length < 3 ||
//                           value.trim().length > 50) {
//                         return ("Enter the Location please");
//                       }
//                       return null;
//                     },
//                     controller: _locationController,
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                         hintText: "Enter the Description"),
//                     validator: (value) {
//                       if (value == null ||
//                           value.isEmpty ||
//                           value.trim().length < 3 ||
//                           value.trim().length > 50) {
//                         return ("Enter the description please");
//                       }
//                       return null;
//                     },
//                     controller: _descriptionController,
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                         hintText: "Enter the Status (Upcoming/ Current/ Past"),
//                     validator: (value) {
//                       if (value == null ||
//                           value.isEmpty ||
//                           value.trim().length < 3 ||
//                           value.trim().length > 50) {
//                         return ("Enter the status please");
//                       }
//                       return null;
//                     },
//                     controller: _statusController,
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () async {
//                           if (keyAddEvent.currentState!.validate()) {
//                             try {
//                               int response = await mydb.insertData(
//                                   '''INSERT INTO Events (Name, Date, Location, Description, Status, UserID)
//   VALUES ("${_nameController.text}", "${_dateController.text}", "${_locationController.text}", "${_descriptionController.text}", "${_statusController.text}", ${widget.friend.ID})''');
//
//                               if (response > 0) {
//                                 setState(() {});
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           EventListPage(friend: widget.friend)),
//                                 );
//                                 setState(() {});
//                                 _nameController.clear();
//                                 _dateController.clear();
//                                 _locationController.clear();
//                                 _descriptionController.clear();
//                                 _statusController.clear();
//                               } else {
//                                 print("Insert failed");
//                               }
//                             } catch (e) {
//                               print("Error inserting data: $e");
//                             }
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue),
//                         child: const Text(
//                           "Save",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               )),
//         ));
//   }
// }
