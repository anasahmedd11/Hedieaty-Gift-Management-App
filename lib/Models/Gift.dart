class Gift {
  final String name;
  final String category;
  bool isLocked;
  final String imageUrl;
  final String Description;
  final num Price;
  final int ID;
  bool isPledged;
  String? FireStoreID;
  final String? eventFirestoreID;

  Gift({
    required this.name,
    required this.category,
    this.isLocked = false,
    required this.imageUrl,
    required this.Description,
    required this.Price,
    required this.ID,
    this.isPledged = false,
    this.FireStoreID,
    this.eventFirestoreID,
  });

  String get status => isLocked ? 'Unpledged' : 'Pledged';
}

