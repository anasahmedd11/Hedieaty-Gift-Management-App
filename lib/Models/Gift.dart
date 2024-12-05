class Gift {
  final String name;
  final String category;
  bool isLocked;
  final String imageUrl;
  final String Description;
  //changed from double to num to match FireStore
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


  // Computed status based on `isLocked` state
  String get status => isLocked ? 'Unpledged' : 'Pledged';
}

