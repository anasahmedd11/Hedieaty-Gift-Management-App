import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Gifts/GiftList.dart';
import 'package:hedieaty_project/Models/Event.dart';

class NewGift extends StatefulWidget {
  const NewGift({required this.event, super.key});

  final Events event;

  @override
  State<StatefulWidget> createState() {
    return _NewGiftState();
  }
}

DataBaseClass mydb = DataBaseClass();

final _giftNameController = TextEditingController();
final _giftDescriptionController = TextEditingController();
final _giftCategoryController = TextEditingController();
final _giftPriceController = TextEditingController();
final _giftPicController = TextEditingController();
final keyAddGift = GlobalKey<FormState>();

class _NewGiftState extends State<NewGift> {
  @override
  void initState() {
    super.initState();
    DataBaseClass mydb = DataBaseClass();
    mydb.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Add New Gift",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: keyAddGift,
              child: Column(
                children: [
                  TextFormField(
                    decoration:
                    const InputDecoration(hintText: "Enter the Name"),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 3 ||
                          value.trim().length > 50) {
                        return ("Check the name please");
                      }
                      return null;
                    },
                    controller: _giftNameController,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        hintText: "Enter the Description"),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 3) {
                        return ("Check the Description please");
                      }
                      return null;
                    },
                    controller: _giftDescriptionController,
                  ),
                  TextFormField(
                    decoration:
                    const InputDecoration(hintText: "Enter the Price"),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length > 50) {
                        return ("Check the Price please");
                      }
                      return null;
                    },
                    controller: _giftPriceController,
                  ),
                  TextFormField(
                    decoration:
                    const InputDecoration(hintText: "Enter the Category"),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 3 ||
                          value.trim().length > 50) {
                        return ("Check the Category please");
                      }
                      return null;
                    },
                    controller: _giftCategoryController,
                  ),
                  TextFormField(
                    decoration:
                    const InputDecoration(hintText: "Enter the Gift Pic"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return ("Check the Pic please");
                      }
                      return null;
                    },
                    controller: _giftPicController,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {

                          if (keyAddGift.currentState!.validate()) {
                            try {
                              int response = await mydb.insertData(
                                  '''INSERT INTO Gifts (Name, Description, Category, Price, GiftPic,EventID) 
  VALUES ("${_giftNameController.text}", "${_giftDescriptionController.text}", "${_giftCategoryController.text}", "${_giftPriceController.text}", "${_giftPicController.text}" ,${widget.event.ID})''');

                              if (response > 0) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GiftListPage(event: widget.event)),
                                );
                                _giftNameController.clear();
                                _giftDescriptionController.clear();
                                _giftCategoryController.clear();
                                _giftPriceController.clear();
                                _giftPicController.clear();
                              } else {
                                print("Insert failed");
                              }
                            } catch (e) {
                              print("Error inserting data: $e");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ));
  }
}
