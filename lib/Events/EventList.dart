// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:hedieaty_project/Database/DatabaseClass.dart';
// import 'package:hedieaty_project/Events/AddEvent.dart';
// import 'package:hedieaty_project/Events/EditEvent.dart';
// import 'package:hedieaty_project/Gifts/GiftList.dart';
// import 'package:hedieaty_project/Models/Event.dart';
// import 'package:hedieaty_project/Models/User.dart';
//
// class EventListPage extends StatefulWidget {
//   const EventListPage({required this.friend, super.key});
//
//   final Userr friend;
//
//   @override
//   _EventListPageState createState() => _EventListPageState();
// }
//
// class _EventListPageState extends State<EventListPage> {
//   DataBaseClass keyEvents = DataBaseClass();
//   List<Map<String, dynamic>> eventData = [];
//   String _sortField = 'name';
//   bool _sortAscending = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadEvents();
//   }
//
//   Future<void> _loadEvents() async {
//     String sqlQuery =
//         "SELECT * FROM 'Events' WHERE UserID = ${widget.friend.ID}";
//     var data = await keyEvents.readData(sqlQuery);
//     setState(() {
//       eventData = List<Map<String, dynamic>>.from(data);
//     });
//   }
//
//   void _sortEvents(String field) {
//     if (_sortField == field) {
//       setState(() {
//         _sortAscending = !_sortAscending;
//       });
//     } else {
//       setState(() {
//         _sortField = field;
//         _sortAscending = true;
//       });
//     }
//   }
//
//   Map<String, int> statusOrder = {
//     'upcoming': 0,
//     'current': 1,
//     'past': 2,
//   };
//
//   List<Map<String, dynamic>> getSortedEvents() {
//     List<Map<String, dynamic>> sortedEvents = List<Map<String, dynamic>>.from(eventData);
//
//     sortedEvents.sort((a, b) {
//       if (_sortField == 'name') {
//         return _sortAscending
//             ? a['Name'].compareTo(b['Name'])
//             : b['Name'].compareTo(a['Name']);
//       } else if (_sortField == 'category') {
//         // Ensure both categories are non-null or use a fallback value (e.g., empty string)
//         String categoryA = a['Category'] ?? '';
//         String categoryB = b['Category'] ?? '';
//
//         return _sortAscending
//             ? categoryA.compareTo(categoryB)
//             : categoryB.compareTo(categoryA);
//       } else if (_sortField == 'status') {
//         // Ensure both statuses are non-null or use a fallback value (e.g., 'upcoming')
//         String statusA = a['Status'] ?? 'upcoming';
//         String statusB = b['Status'] ?? 'upcoming';
//
//         // Compare status based on the predefined order with null checks
//         int statusComparison = statusOrder[statusA] ?? -1;  // Use -1 if the status doesn't exist
//         int statusBValue = statusOrder[statusB] ?? -1;  // Use -1 if the status doesn't exist
//
//         return _sortAscending
//             ? statusComparison.compareTo(statusBValue)
//             : statusBValue.compareTo(statusComparison);
//       }
//       return 0;
//     });
//
//     return sortedEvents;
//   }
//
//
//   void _navigateToGiftListPage(Events event) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => GiftListPage(event: event),
//       ),
//     );
//   }
//
//   void _onEventUpdated() {
//     _loadEvents();
//   }
//
//   Future<void> deleteEventFromFirestore(int eventId) async {
//     try {
//       FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//       // Replace the friend's ID with the actual document reference
//       String friendIdStr = widget.friend.ID.toString();
//
//       // Reference to the event in Firestore
//       QuerySnapshot eventSnapshot = await firestore
//           .collection('friends')
//           .doc(friendIdStr)
//           .collection('events')
//           .where('eventID', isEqualTo: eventId)  // Use the event ID or another identifier
//           .get();
//
//       if (eventSnapshot.docs.isNotEmpty) {
//         // If the event is found, delete it
//         await eventSnapshot.docs.first.reference.delete();
//         print("Event deleted from Firestore");
//       } else {
//         print("Event not found in Firestore");
//       }
//     } catch (e) {
//       print("Error deleting event from Firestore: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Map<String, dynamic>> sortedEvents = getSortedEvents();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.friend.name}\'s Events',
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           PopupMenuButton<String>(
//             iconColor: Colors.white,
//             onSelected: (value) {
//               _sortEvents(value); // Trigger sorting based on selected value
//             },
//             itemBuilder: (context) {
//               return const [
//                 PopupMenuItem<String>(
//                   value: 'name',
//                   child: Text('Sort by Name'),
//                 ),
//                 PopupMenuItem<String>(
//                   value: 'category',
//                   child: Text('Sort by Category'),
//                 ),
//                 PopupMenuItem<String>(
//                   value: 'status',
//                   child: Text('Sort by Status'),
//                 ),
//               ];
//             },
//           )
//
//         ],
//       ),
//       body: eventData.isEmpty
//           ? const Center(
//         child: Text(
//           'No events for this friend yet!',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//       )
//           : ListView.builder(
//         itemCount: sortedEvents.length,
//         itemBuilder: (context, index) {
//           var event = Events(
//             name: sortedEvents[index]['Name'],
//             Date: sortedEvents[index]['Date'],
//             Location: sortedEvents[index]['Location'],
//             Description: sortedEvents[index]['Description'],
//             ID: sortedEvents[index]['ID'],
//             status: sortedEvents[index]['Status'],
//           );
//
//           return Padding(
//             padding:
//             const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5),
//             child: Card(
//               color: Colors.blue,
//               child: ListTile(
//                 title: Text(
//                   event.name,
//                   style: const TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text(
//                   '${event.Location} - ${event.Date} - ${event.status}',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit, color: Colors.white),
//                       onPressed: () async {
//                         bool? result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EditEvent(
//                               event: event,
//                               onEventUpdated: _onEventUpdated,
//                             ),
//                           ),
//                         );
//                         if (result != null && result) {
//                           _loadEvents(); // Refresh after going back from EditEvent
//                         }
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.white),
//                       onPressed: () async {
//                         int response = await keyEvents.deleteData(
//                             "DELETE FROM Events WHERE ID= ${sortedEvents[index]['ID']}");
//                         if (response > 0) {
//                           await deleteEventFromFirestore(sortedEvents[index]['ID']);
//                           _loadEvents();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: const Text('Event Deleted'),
//                             ),
//                           );
//                         };
//                       },
//                     ),
//                   ],
//                 ),
//                 onTap: () {
//                   _navigateToGiftListPage(event);
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => NewEvent(friend: widget.friend),
//               ));
//         },
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }
