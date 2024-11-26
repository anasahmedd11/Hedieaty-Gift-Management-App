import 'gift.dart';

class Events {
  final String name;
  final String Date;
  final String Location;
  final String Description;
  final String status;
  final List<Gift> gifts; // List of gifts associated with the event
  int ID;

  Events({
    required this.name,
    required this.Date,
    required this.Location,
    required this.Description,
    required this.ID,
    required this.status,
    this.gifts = const [],
  });
}
