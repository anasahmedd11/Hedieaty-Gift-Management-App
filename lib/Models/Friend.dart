import 'package:hedieaty_project/Models/Event.dart';

class Friend {
  Friend({
    required this.id,
    required this.name,
    required this.profilePic,
    this.upcomingEvents = 0,
    List<Events>? events, // Make it optional to initialize
  }) : events = events ?? []; // Initialize to an empty list if null

  final String id;
  final String name;
  final String profilePic;
  int upcomingEvents; // Change to allow updates
  List<Events> events; // List of events associated with the friend
}
