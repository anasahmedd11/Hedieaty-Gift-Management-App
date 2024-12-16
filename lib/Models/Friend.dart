import 'package:hedieaty_project/Models/Event.dart';

class Friend {
  Friend({
    required this.id,
    required this.name,
    required this.profilePic,
    this.upcomingEvents = 0,
    List<Events>? events,
  }) : events = events ?? [];

  final String id;
  final String name;
  final String profilePic;
  int upcomingEvents;
  List<Events> events;
}
