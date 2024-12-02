import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:hedieaty_project/Models/Event.dart';
import '../Models/Gift.dart';
import 'AddUserGift.dart';
import 'EditUserGift.dart';

class UserGiftListPage extends StatefulWidget {
  final Events event;

  const UserGiftListPage({required this.event, Key? key}) : super(key: key);

  @override
  _UserGiftListPageState createState() => _UserGiftListPageState();
}

class _UserGiftListPageState extends State<UserGiftListPage> {
  List<Map<String, dynamic>> giftData = [];
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      String userUID = user.uid;
      String eventFirestoreID = widget.event.FireStoreID ?? 'zero';

      QuerySnapshot firestoreGifts = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userUID)
          .collection('Events')
          .doc(eventFirestoreID)
          .collection('Gifts')
          .get();

      setState(() {
        giftData = firestoreGifts.docs.map((doc) {
          return {
            'ID': doc.id,
            'Name': doc['Name'],
            'Description': doc['Description'],
            'Category': doc['Category'],
            'Price': (doc['Price'] as num).toDouble(),
            'GiftPic': doc['GiftPic'],
            'isPledged': doc['isPledged'] ?? false,
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading gifts: $e");
    }
  }

  void _deleteGift(String firestoreID) async {
    String loggedInUserID = user?.uid ?? "";
    if (loggedInUserID.isEmpty) {
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(loggedInUserID)
          .collection('Events')
          .doc(widget.event.FireStoreID)
          .collection('Gifts')
          .doc(firestoreID)
          .delete();
      _loadGifts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting gift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          '${widget.event.name} Gifts',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: giftData.isEmpty
          ? const Center(
              child: Text(
                'No gifts added yet!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
              ),
              itemCount: giftData.length,
              itemBuilder: (context, index) {
                final gift = giftData[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                  clipBehavior: Clip.hardEdge,
                  elevation: 2,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => GiftDetailsPage(giftId: sortedGifts[index]['ID'])));
                        },
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: FadeInImage(
                            placeholder: MemoryImage(kTransparentImage),
                            image: NetworkImage(gift['GiftPic']),
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black87,
                          child: Column(
                            children: [
                              Text(
                                gift['Name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _deleteGift(gift['ID']);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final result =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => EditUserGift(
                                              gift: Gift(
                                                ID: int.tryParse(gift['ID']
                                                        .toString()) ??
                                                    0,
                                                name: gift['Name'],
                                                category: gift['Category'],
                                                Description:
                                                    gift['Description'],
                                                Price: double.tryParse(
                                                        gift['Price']
                                                            .toString()) ??
                                                    0.0,
                                                imageUrl: gift['GiftPic'],
                                                FireStoreID: gift['ID'],
                                                eventFirestoreID:
                                                    widget.event.FireStoreID!,
                                              ),
                                              onGiftUpdated: _loadGifts,
                                            ),
                                          ),
                                        );
                                        if (result == true) _loadGifts();
                                      },
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewGift(event: widget.event),
            ),
          );

          if (result == true) {
            _loadGifts();
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
