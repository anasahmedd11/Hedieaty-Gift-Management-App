import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Friends/FriendsGiftList.dart';
import 'package:hedieaty_project/Models/Event.dart';
import 'package:hedieaty_project/Models/User.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({required this.friend, super.key});

  final Userr friend;

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  DataBaseClass keyEvents = DataBaseClass();
  List<Map<String, dynamic>> eventData = [];
  String _sortField = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  bool _isLoading = true;

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String friendFirestoreID = widget.friend.FirestoreID!;

      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Friends')
          .doc(friendFirestoreID)
          .collection('Events')
          .get();

      // Debug print to check retrieved documents
      for (var doc in eventsSnapshot.docs) {
        print(doc.data()); // Output the data of each event
      }

      setState(() {
        eventData = eventsSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'Name': data['Name'] ?? 'No Name',
            'Date': data['Date'] ?? 'No Date',
            'Location': data['Location'] ?? 'No Location',
            'Description': data['Description'] ?? 'No Description',
            'Status': data['Status'] ?? 'No Status',
            'FireStoreID': doc.id,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading events: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      } else if (_sortField == 'location') {
        // Ensure both categories are non-null or use a fallback value (e.g., empty string)
        String categoryA = a['Location'] ?? '';
        String categoryB = b['Location'] ?? '';

        return _sortAscending
            ? categoryA.compareTo(categoryB)
            : categoryB.compareTo(categoryA);
      } else if (_sortField == 'status') {
        // Ensure both statuses are non-null or use a fallback value (e.g., 'upcoming')
        String statusA = a['Status'] ?? 'upcoming';
        String statusB = b['Status'] ?? 'upcoming';

        // Compare status based on the predefined order with null checks
        int statusComparison =
            statusOrder[statusA] ?? -1; // Use -1 if the status doesn't exist
        int statusBValue =
            statusOrder[statusB] ?? -1; // Use -1 if the status doesn't exist

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
        title: FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: Text('${widget.friend.name}\'s Events',
              style: const TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (value) {
              _sortEvents(value);
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'name',
                  child: Text('Sort by Name'),
                ),
                PopupMenuItem<String>(
                  value: 'location',
                  child: Text('Sort by Location'),
                ),
                PopupMenuItem<String>(
                  value: 'status',
                  child: Text('Sort by Status'),
                ),
              ];
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : eventData.isEmpty
              ? const Center(
                  child: Text(
                    'No events for this friend yet!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: sortedEvents.length,
                  itemBuilder: (context, index) {
                    Random random = Random();
                    var event = Events(
                      ID: random.nextInt(10000),
                      name: sortedEvents[index]['Name'],
                      Date: sortedEvents[index]['Date'],
                      Location: sortedEvents[index]['Location'],
                      Description: sortedEvents[index]['Description'],
                      status: sortedEvents[index]['Status'],
                      FireStoreID: sortedEvents[index]['FireStoreID'],
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 5),
                      child: Animate(
                        effects: [
                          SlideEffect(
                            begin: Offset(2, 0),
                            // first value represents x, second represents y
                            end: Offset.zero,
                            duration: 900.ms,
                            curve: Curves.easeInOut,
                          ),
                        ],
                        child: Card(
                          color: Colors.blue,
                          child: ListTile(
                            title: Text(
                              event.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${event.Location} - ${event.Date} - ${event.status}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return GiftListPage(
                                      event: event,
                                      friend: widget.friend,
                                    );
                                  },
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    // Customize duration
                                    var tween = Tween(begin: 0.0, end: 1.0)
                                        .chain(CurveTween(
                                            curve: Curves.easeInOut));
                                    var scaleAnimation = animation.drive(tween);

                                    return ScaleTransition(
                                      scale: scaleAnimation,
                                      child: FadeTransition(
                                          opacity: animation, child: child),
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 700),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
