class Userr {
  String name;
  String email;
  String profileImageUrl;
  int ID;
  String PhoneNumber;
  String? FirestoreID;

  Userr({
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.ID,
    required this.PhoneNumber,
    this.FirestoreID,
  });
}
