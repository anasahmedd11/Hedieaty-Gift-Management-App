import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Models/Gift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditUserGift extends StatefulWidget {
  final Gift gift;
  final void Function() onGiftUpdated;

  const EditUserGift({required this.gift, required this.onGiftUpdated, super.key});

  @override
  _EditGiftPageState createState() => _EditGiftPageState();
}

class _EditGiftPageState extends State<EditUserGift> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DataBaseClass _mydb = DataBaseClass();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.gift.name;
    _categoryController.text = widget.gift.category;
    _descriptionController.text = widget.gift.Description;
    _priceController.text = widget.gift.Price.toString();
    _imageUrlController.text = widget.gift.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _editGiftData() async {
    if (_formKey.currentState!.validate()) {
      try {
        String updatedName = _nameController.text.trim();
        String updatedCategory = _categoryController.text.trim();
        String updatedDescription = _descriptionController.text.trim();
        double updatedPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
        String updatedImageUrl = _imageUrlController.text.trim();

        // Check if the gift exists in the local database
        String selectQuery = '''
      SELECT * FROM Gifts WHERE FireStoreID = "${widget.gift.FireStoreID}"
      ''';
        var result = await _mydb.readData(selectQuery);
        if (result.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gift not found in the local database.")),
          );
          return;
        }

        // Update the local database
        String sqlQuery = '''
      UPDATE Gifts
      SET Name = "$updatedName",
          Category = "$updatedCategory",
          Description = "$updatedDescription",
          Price = $updatedPrice,
          GiftPic = "$updatedImageUrl"
      WHERE FireStoreID = "${widget.gift.FireStoreID}"
      ''';
        int response = await _mydb.updateData(sqlQuery);

        // Update Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .collection('Events')
                .doc(widget.gift.eventFirestoreID)
                .collection('Gifts')
                .doc(widget.gift.FireStoreID)
                .update({
              'Name': updatedName,
              'Category': updatedCategory,
              'Description': updatedDescription,
              'Price': updatedPrice,
              'GiftPic': updatedImageUrl,
            });
            print("Firestore update successful");
          } catch (error) {
            print("Error updating Firestore: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error updating FireStore: $error")),
            );
          }
        }

        if (response > 0) {
          widget.onGiftUpdated(); // Notify the parent widget to refresh the gift list
          Navigator.pop(context, true); // Go back to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update the gift.")),
          );
        }
      } catch (e) {
        print("Error updating gift: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while updating.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInUp(duration: const Duration(milliseconds: 1000),child: const Text("Edit Gift", style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Gift Name'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().length < 2||
                      value.trim().length > 50) {
                    return 'Please enter a valid gift name (min 2 characters).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty||value.trim().length < 3 ||
                      value.trim().length > 50) {
                    return 'Please enter a valid gift category (min 3 characters).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 3 ||
                      value.trim().length > 50) {
                    return 'Please enter a valid gift description (min 3 characters).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Gift price can\'t be negative or 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid image URL.';
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _editGiftData, // Save changes
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
