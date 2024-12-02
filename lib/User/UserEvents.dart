import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty_project/Models/Event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty_project/User/EditUserEvent.dart';
import 'package:hedieaty_project/User/UserGiftList.dart';
import '../Events/EditEvent.dart';

class UserEvents extends StatefulWidget {
  const UserEvents({super.key});

  @override
  _UserEventsState createState() => _UserEventsState();
}

class _UserEventsState extends State<UserEvents> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> eventData = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    String loggedInUserID = user?.uid ?? "";
    if (loggedInUserID.isEmpty) {
      return;
    }

    // Fetch events from FireStore
    QuerySnapshot firestoreEvents = await FirebaseFirestore.instance
        .collection('Users')
        .doc(loggedInUserID)
        .collection('Events')
        .get();

    // Add events to the local list
    setState(() {
      eventData = firestoreEvents.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'Name': data['Name'],
          'Date': data['Date'],
          'Location': data['Location'],
          'Description': data['Description'],
          'Status': data['Status'],
          'FireStoreID': doc.id,
        };
      }).toList();
    });
  }

  void _deleteEvent(String firestoreID) async {
    String loggedInUserID = user?.uid ?? "";
    if (loggedInUserID.isEmpty) {
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(loggedInUserID)
          .collection('Events')
          .doc(firestoreID)
          .delete();
      _loadEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.displayName}\'s Events',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: eventData.isEmpty
          ? const Center(
              child: Text(
                'No events for this user yet!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: eventData.length,
              itemBuilder: (context, index) {
                var event = Events(
                  name: eventData[index]['Name'],
                  Date: eventData[index]['Date'],
                  Location: eventData[index]['Location'],
                  Description: eventData[index]['Description'],
                  ID: eventData[index]['ID'] ?? 0,
                  status: eventData[index]['Status'] ?? 'Unknown',
                  FireStoreID: eventData[index]['FireStoreID'],
                );
                return InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserGiftListPage(event: event),));
                  },
                  child: Card(
                    color: Colors.blue,
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: ListTile(
                      title: Text(
                        event.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${event.Location} - ${event.Date} - ${event.status}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditUserEvent(
                                    event: event,
                                    onEventUpdated: _loadEvents,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              _deleteEvent(event.FireStoreID!);
                            },
                          ),
                        ],
                      ), // Navigate to EditEvent on tap
                    ),
                  ),
                );
              },
            ),
    );
  }
}
