// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// class NewEvent extends StatefulWidget {
//   final String friendID; // Firestore ID of the friend
//
//   const NewEvent({required this.friendID, super.key});
//
//   @override
//   State<StatefulWidget> createState() => _NewEventState();
// }
//
// class _NewEventState extends State<NewEvent> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//
//   Future<void> _saveEvent() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//         await firestore
//             .collection('Friends')
//             .doc(widget.friendID)
//             .collection('Events')
//             .add({
//           'Name': _nameController.text.trim(),
//           'Date': _dateController.text.trim(),
//           'Location': _locationController.text.trim(),
//           'Description': _descriptionController.text.trim(),
//           'Status': 'upcoming', // Default status
//         });
//
//         Navigator.pop(context); // Go back to the events list
//       } catch (e) {
//         print("Error saving event: $e");
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Event"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: "Event Name"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return "Enter event name";
//                   return null;
//                 },
//               ),
//               // Add other fields for date, location, description...
//               ElevatedButton(
//                 onPressed: _saveEvent,
//                 child: const Text("Save Event"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
