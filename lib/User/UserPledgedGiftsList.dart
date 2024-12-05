import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hedieaty_project/Models/Gift.dart';
import 'package:hedieaty_project/Models/Event.dart';
import 'package:hedieaty_project/Models/User.dart';

class PledgedGiftsPage extends StatefulWidget {
  const PledgedGiftsPage({
    required this.event,
    required this.friend,
    super.key,
  });

  final Events event;
  final Userr friend;

  @override
  State<PledgedGiftsPage> createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  List<Gift> pledgedGifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  // Fetch pledged gifts from Firestore
  Future<void> _loadPledgedGifts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      QuerySnapshot giftSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Friends')
          .doc(widget.friend.FirestoreID) // Friend's FirestoreID
          .collection('Events')
          .doc(widget.event.FireStoreID) // Event's FirestoreID
          .collection('Gifts')
          .where('isPledged', isEqualTo: 1) // Only pledged gifts
          .get();

      setState(() {
        pledgedGifts = giftSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return Gift(
            ID: 1,
            name: data['Name'] ?? '',
            Price: data['Price'] ?? 0,
            category: data['Category'] ?? '',
            Description: data['Description'] ?? '',
            imageUrl: data['GiftPic'] ?? '',
            FireStoreID: doc.id,
            isPledged: data['isPledged'] == 1,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading pledged gifts: $e");
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
            child: const Text('Pledged Gifts',
                style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pledgedGifts.isEmpty
              ? const Center(
                  child: Text(
                    'No gifts pledged yet!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: pledgedGifts.length,
                  itemBuilder: (context, index) {
                    var gift = pledgedGifts[index];
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Animate(
                        effects: [
                          SlideEffect(
                            begin: Offset(0, 2), // first value represents x, second represents y
                            end: Offset.zero,    // Slide to the original position
                            duration: 900.ms,
                            curve: Curves.easeInOut,
                          ),
                        ],
                        child: Card(
                          color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(gift.imageUrl),
                              ),
                              title: Text(
                                '${widget.friend.name}\'s Pledged Gift',
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${gift.name} - ${gift.Price}\$',
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
