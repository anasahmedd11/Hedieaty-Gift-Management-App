class Gift {
  final String name;
  final String category;
  bool isLocked;
  final String imageUrl;
  final String Description;
  final String Price;
  final int ID;
  bool isPledged;

  Gift({
    required this.name,
    required this.category,
    this.isLocked = false,
    required this.imageUrl,
    required this.Description,
    required this.Price,
    required this.ID,
    this.isPledged = false,
  });


  // Computed status based on `isLocked` state
  String get status => isLocked ? 'Unpledged' : 'Pledged';
}

