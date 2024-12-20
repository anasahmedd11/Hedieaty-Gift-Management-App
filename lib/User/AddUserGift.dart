import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Models/Event.dart';

class NewGift extends StatefulWidget {
  final Events event;

  const NewGift({required this.event, super.key});

  @override
  _NewGiftState createState() => _NewGiftState();
}

class _NewGiftState extends State<NewGift> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final mydb = DataBaseClass();

  Future<void> saveGift() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userUID = user.uid;

      // Prepare data for the local database
      String name = _nameController.text.trim();
      String description = _descriptionController.text.trim();
      String category = _categoryController.text.trim();
      double price = double.parse(_priceController.text.trim());
      String giftPic = _imageController.text.trim();
      int isPledged = 0; // Default to not pledged (0 for local DB)

      // Insert gift into the local database
      int localDBID = await mydb.insertData('''
      INSERT INTO Gifts (Name, Description, Category, Price, GiftPic, isPledged, EventID)
      VALUES ("$name", "$description", "$category", $price, "$giftPic", $isPledged, ${widget.event.ID})
    ''');

      // Prepare data for Firestore
      Map<String, dynamic> giftData = {
        'Name': name,
        'Description': description,
        'Category': category,
        'Price': price,
        'GiftPic': giftPic,
        'isPledged': false, // Default to not pledged (false for Firestore)
        'LocalDBID': localDBID,
      };

      // Add gift to Firestore under the current user's event
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userUID)
          .collection('Events')
          .doc(widget.event.FireStoreID)
          .collection('Gifts')
          .add(giftData);

      // After saving to Firestore, update the local database with Firestore ID
      String firestoreID = docRef.id;
      String updateQuery = '''
      UPDATE Gifts SET FireStoreID = '$firestoreID' WHERE ID = $localDBID
    ''';
      await mydb.updateData(updateQuery);

      // Clear the input fields
      _nameController.clear();
      _descriptionController.clear();
      _categoryController.clear();
      _priceController.clear();
      _imageController.clear();

      Navigator.pop(context, true); // Indicate success
    } catch (e) {
      print("Error saving gift: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: const Text(
            "Add New Gift",
            style: TextStyle(color: Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  key: ValueKey('addGiftNameTextFormField'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Enter the Name'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 2 ||
                        value.trim().length > 50) {
                      return 'Please enter a valid gift name (min 2 characters and max 50 characters).';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: ValueKey('addGiftDescriptionTextFormField'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Enter the Description'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 3 ||
                        value.trim().length > 50) {
                      return 'Please enter a valid gift description (min 3 characters and max 50 characters).';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: ValueKey('addGiftCategoryTextFormField'),
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Enter the Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty||value.trim().length < 3 ||
                        value.trim().length > 50) {
                      return 'Please enter a valid gift category (min 3 characters and max 50 characters).';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: ValueKey('addGiftPriceTextFormField'),
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Enter the Price (\$)'),
                  validator: (value) {
                    if (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Gift price can\'t be negative or 0';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: ValueKey('addGiftImageTextFormField'),
                  controller: _imageController,
                  decoration: const InputDecoration(labelText: 'Enter the Image URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter the profile pic please";
                    }
            
                    // Check if the entered value is a valid URL
                    Uri? uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return "Enter a valid URL for the profile pic";
                    }
            
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      key: const ValueKey('addUserGiftSubmitButton'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: saveGift,
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
