import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Models/Gift.dart';

class EditGiftPage extends StatefulWidget {
  final Gift gift;
  final void Function() onGiftUpdated;

  const EditGiftPage({required this.gift, required this.onGiftUpdated, super.key});

  @override
  _EditGiftPageState createState() => _EditGiftPageState();
}

class _EditGiftPageState extends State<EditGiftPage> {
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
    _priceController.text = widget.gift.Price as String;
    _imageUrlController.text = widget.gift.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateGiftData() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Prepare the SQL query to update the gift
        String sqlQuery = '''
          UPDATE Gifts
          SET Name = "${_nameController.text}",
              Category = "${_categoryController.text}",
              Description = "${_descriptionController.text}",
              Price = "${_priceController.text}",
              GiftPic = "${_imageUrlController.text}"
          WHERE ID = ${widget.gift.ID}
        ''';

        // Update the gift in the database using your database helper class
        int response = await _mydb.updateData(sqlQuery);

        // If the update was successful
        if (response > 0) {
          widget.onGiftUpdated(); // Notify the parent widget that the gift has been updated
          Navigator.pop(context, true); // Close the edit page and go back
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
        title: const Text("Edit Gift",style: TextStyle(color: Colors.white),),
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
                  if (value == null || value.isEmpty || value.trim().length < 3) {
                    return 'Please enter a valid gift name (min 3 characters).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid category.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description.';
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid price.';
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
                      Navigator.pop(context); // Cancel and go back
                    },
                    child: const Text('Cancel',style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _updateGiftData, // Save changes
                    child: const Text('Save Changes',style: TextStyle(color: Colors.white)),
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
