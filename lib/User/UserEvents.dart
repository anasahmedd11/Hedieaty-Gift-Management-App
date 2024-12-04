import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hedieaty_project/Models/Event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty_project/User/EditUserEvent.dart';
import 'package:hedieaty_project/User/UserGiftList.dart';
import 'AddUserEvent.dart';

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

  String _sortField = 'name';
  bool _sortAscending = true;

  void _sortEvents(String field) {
    if (_sortField == field) {
      setState(() {
        _sortAscending = !_sortAscending;
      });
    } else {
      setState(() {
        _sortField = field;
        _sortAscending = true;
      });
    }
  }

  Map<String, int> statusOrder = {
    'upcoming': 0,
    'current': 1,
    'past': 2,
  };

  List<Map<String, dynamic>> getSortedEvents() {
    List<Map<String, dynamic>> sortedEvents =
        List<Map<String, dynamic>>.from(eventData);

    sortedEvents.sort((a, b) {
      if (_sortField == 'name') {
        return _sortAscending
            ? a['Name'].compareTo(b['Name'])
            : b['Name'].compareTo(a['Name']);
      } else if (_sortField == 'date') {
        String dateA = a['Date'];
        String dateB = b['Date'];
        return _sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      } else if (_sortField == 'status') {
        // Fallback value 'upcoming' in case of nulls
        String statusA = a['Status'] ?? 'upcoming';
        String statusB = b['Status'] ?? 'upcoming';

        // -1 if the status doesn't exist
        int statusComparison = statusOrder[statusA] ?? -1;
        int statusBValue = statusOrder[statusB] ?? -1;

        return _sortAscending
            ? statusComparison.compareTo(statusBValue)
            : statusBValue.compareTo(statusComparison);
      }
      return 0;
    });

    return sortedEvents;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sortedEvents = getSortedEvents();
    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.displayName}\'s Events',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Animate(
            effects: [
              SlideEffect(
                begin: Offset(2, 0), // first value represents x, second represents y
                end: Offset.zero,    // Slide to the original position
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
            ],
            child: PopupMenuButton<String>(
              iconColor: Colors.white,
              onSelected: (value) {
                _sortEvents(value); // Trigger sorting based on selected value
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<String>(
                    value: 'name',
                    child: Text('Sort by Name'),
                  ),
                  PopupMenuItem<String>(
                    value: 'date',
                    child: Text('Sort by Date'),
                  ),
                  PopupMenuItem<String>(
                    value: 'status',
                    child: Text('Sort by Status'),
                  ),
                ];
              },
            ),
          )
        ],
      ),
      body: eventData.isEmpty
          ? const Center(
              child: Text(
                'No events for this user yet!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: sortedEvents.length,
              itemBuilder: (context, index) {
                var event = Events(
                  name: sortedEvents[index]['Name'],
                  Date: sortedEvents[index]['Date'],
                  Location: sortedEvents[index]['Location'],
                  Description: sortedEvents[index]['Description'],
                  ID: sortedEvents[index]['ID'] ?? 0,
                  status: sortedEvents[index]['Status'] ?? 'Unknown',
                  FireStoreID: sortedEvents[index]['FireStoreID'],
                );
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return UserGiftListPage(event: event);
                        },
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var offsetTween =
                              Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
                          var offsetAnimation = animation.drive(offsetTween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                        transitionDuration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.blue,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
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
                          Animate(
                            effects: [
                              BlurEffect(
                                end: Offset(0.0, 0.0),
                                begin: Offset(3.0, 3.0),
                                duration: 500.ms,
                              ),
                            ],
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation, secondaryAnimation) {
                                      return EditUserEvent(
                                        event: event,
                                        onEventUpdated: _loadEvents,
                                      );
                                    },
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      var offsetTween = Tween(
                                          begin: Offset(1.0, 0.0),
                                          end: Offset.zero);
                                      var offsetAnimation =
                                          animation.drive(offsetTween);
                                      return SlideTransition(
                                          position: offsetAnimation,
                                          child: child);
                                    },
                                    transitionDuration:
                                        Duration(milliseconds: 500),
                                  ),
                                );
                              },
                            ),
                          ),
                          Animate(
                            effects: [
                              BlurEffect(
                                end: Offset(0.0, 0.0),
                                begin: Offset(3.0, 3.0),
                                duration: 500.ms,
                              ),
                            ],
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                _deleteEvent(event.FireStoreID!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Animate(
        effects: [
          ShakeEffect(
            offset: Offset(10, 0), // Horizontal shake
            duration: 1000.ms,
            curve: Curves.elasticInOut,
          ),
        ],
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return AddUserEvent();
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var tween = Tween(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeInOut));
                  var scaleAnimation = animation.drive(tween);

                  return ScaleTransition(
                    scale: scaleAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
