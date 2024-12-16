import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty_project/Models/Gift.dart';
import 'package:hedieaty_project/Models/User.dart';
import 'package:hedieaty_project/Models/Event.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift;
  final Userr friend;
  final Events event;

  const GiftDetailsPage({
    required this.gift,
    required this.friend,
    required this.event,
    Key? key,
  }) : super(key: key);

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  Map<String, dynamic>? giftDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGiftDetails();
  }

  Future<void> _loadGiftDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch the gift details from Firestore
      var giftDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Friends')
          .doc(widget.friend.FirestoreID)
          .collection('Events')
          .doc(widget.event.FireStoreID)
          .collection('Gifts')
          .doc(widget.gift.FireStoreID)
          .get();

      if (giftDoc.exists) {
        setState(() {
          giftDetails = giftDoc.data();
          _isLoading = false;
        });
      } else {
        print("Gift not found!");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching gift details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: Text(
            giftDetails?['Name'] ?? 'Gift Details',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : giftDetails == null
              ? const Center(
                  child: Text(
                    'Gift details not available.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.network(
                        giftDetails!['GiftPic'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Icon(Icons.broken_image, size: 100),
                        ),
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(),
                                );
                        },
                      ),
                    ),
                    // DraggableScrollableSheet
                    DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      minChildSize: 0.3,
                      maxChildSize: 0.8,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Container(
                                      height: 5,
                                      width: 50,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    giftDetails!['Name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Status:",
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Center(
                                          child: Text(
                                            giftDetails!['isPledged'] == 1
                                                ? "Pledged"
                                                : "Available",
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style:
                                                const TextStyle(fontSize: 19),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Category:",
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Center(
                                          child: Text(
                                            giftDetails!['Category'],
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style:
                                                const TextStyle(fontSize: 19),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Price:",
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Center(
                                          child: Text(
                                            "${giftDetails!['Price']}\$",
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style:
                                                const TextStyle(fontSize: 19),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Description:",
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Center(
                                          child: Text(
                                            giftDetails!['Description'] ??
                                                "No description",
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style:
                                                const TextStyle(fontSize: 19),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}
