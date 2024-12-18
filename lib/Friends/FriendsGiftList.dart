import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hedieaty_project/Models/Event.dart';
import 'package:hedieaty_project/Models/Gift.dart';
import 'package:hedieaty_project/Friends/FriendGiftDetails.dart';
import 'package:transparent_image/transparent_image.dart';
import '../Notifications/LocalNotifications.dart';
import '../User/UserPledgedGiftsList.dart';
import '../Models/User.dart';

class GiftListPage extends StatefulWidget {
  final Events event;
  final Userr friend;

  const GiftListPage({required this.friend, required this.event, super.key});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [];
  bool _isLoading = true;
  String _sortField = 'name'; // Default sort by name
  bool _sortAscending = true; // Default to ascending order

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  final user = FirebaseAuth.instance.currentUser;

  // Fetch gifts from Firestore for this event
  Future<void> _loadGifts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch the gifts related to this event
      QuerySnapshot giftSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Friends')
          .doc(widget.friend.FirestoreID) // Friend's FirestoreID
          .collection('Events')
          .doc(widget.event.FireStoreID) // Event's FirestoreID
          .collection('Gifts')
          .get();

      print("Number of gifts fetched: ${giftSnapshot.docs.length}");

      setState(() {
        gifts = giftSnapshot.docs.map((doc) {
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
      print("Error loading gifts: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sort the gifts based on selected field
  void _sortGifts(String field) {
    if (_sortField == field) {
      setState(() {
        _sortAscending = !_sortAscending;
      });
    } else {
      setState(() {
        _sortField = field;
        _sortAscending =
            true; // Reset to ascending when a new field is selected
      });
    }
  }

  // Sorting gifts based on selected field
  List<Gift> getSortedGifts() {
    List<Gift> sortedGifts = List<Gift>.from(gifts);

    sortedGifts.sort((a, b) {
      if (_sortField == 'name') {
        return _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name);
      } else if (_sortField == 'category') {
        return _sortAscending
            ? a.category.compareTo(b.category)
            : b.category.compareTo(a.category);
      } else if (_sortField == 'price') {
        return _sortAscending
            ? a.Price.compareTo(b.Price)
            : b.Price.compareTo(a.Price);
      } else if (_sortField == 'pledgeStatus') {
        // Converting bool values to int for comparison
        int pledgeStatusA = a.isPledged ? 1 : 0;
        int pledgeStatusB = b.isPledged ? 1 : 0;
        return _sortAscending
            ? pledgeStatusA.compareTo(pledgeStatusB)
            : pledgeStatusB.compareTo(pledgeStatusA);
      } else if (_sortField == 'eventDate') {
        DateTime eventDateA = DateTime.parse(
            widget.event.Date); // Assuming you store event date as a string
        DateTime eventDateB = DateTime.parse(widget.event.Date);

        return _sortAscending
            ? eventDateA.compareTo(eventDateB)
            : eventDateB.compareTo(eventDateA);
      }
      return 0;
    });

    return sortedGifts;
  }

  @override
  Widget build(BuildContext context) {
    List<Gift> sortedGifts = getSortedGifts();

    return Scaffold(
      appBar: AppBar(
        title: FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: Text('${widget.event.name} Gifts',
              style: const TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (value) {
              _sortGifts(value);
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                    value: 'name', child: Text('Sort by Name')),
                PopupMenuItem<String>(
                    value: 'category', child: Text('Sort by Category')),
                PopupMenuItem<String>(
                    value: 'pledgeStatus',
                    child: Text('Sort by Pledge Status')),
                PopupMenuItem<String>(
                    value: 'price', child: Text('Sort by Price')),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : sortedGifts.isEmpty
              ? const Center(
                  child: Text(
                    'No gifts added yet!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Animate(
                        effects: [
                          SlideEffect(
                            begin: Offset(0, 2),
                            // first value represents x, second represents y
                            end: Offset.zero,
                            // Slide to the original position
                            duration: 900.ms,
                            curve: Curves.easeInOut,
                          ),
                        ],
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PledgedGiftsPage(
                                event: widget.event,
                                friend: widget.friend,
                              ),
                            ));
                          },
                          key: ValueKey('viewPledgedGiftsButton'),
                          child: const Text(
                            "View Pledged Gifts",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: sortedGifts.length,
                        itemBuilder: (context, index) {
                          var gift = sortedGifts[index];

                          return Animate(
                            effects: [
                              SlideEffect(
                                begin: Offset(0, 2),
                                // first value represents x, second represents y
                                end: Offset.zero,
                                // Slide to the original position
                                duration: 900.ms,
                                curve: Curves.easeInOut,
                              ),
                            ],
                            child: Card(
                              margin: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7)),
                              clipBehavior: Clip.hardEdge,
                              elevation: 2,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GiftDetailsPage(
                                                    friend: widget.friend,
                                                    event: widget.event,
                                                    gift: gift,
                                                  )));
                                    },
                                    child: BackdropFilter(
                                      filter: gift.isPledged
                                          ? ImageFilter.blur(
                                              sigmaX: 5.0, sigmaY: 5.0)
                                          : ImageFilter.blur(
                                              sigmaX: 0.0, sigmaY: 0.0),
                                      child: FadeInImage(
                                        placeholder:
                                            MemoryImage(kTransparentImage),
                                        image: NetworkImage(gift.imageUrl),
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
                                            gift.name,
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(width: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        try {
                                                          // Toggle the isPledged value
                                                          bool newPledgeStatus =
                                                              !gift.isPledged;

                                                          // Update the Firestore document
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Users')
                                                              .doc(FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid)
                                                              .collection(
                                                                  'Friends')
                                                              .doc(widget.friend
                                                                  .FirestoreID)
                                                              .collection(
                                                                  'Events')
                                                              .doc(widget.event
                                                                  .FireStoreID)
                                                              .collection(
                                                                  'Gifts')
                                                              .doc(gift
                                                                  .FireStoreID)
                                                              .update({
                                                            'isPledged':
                                                                newPledgeStatus
                                                                    ? 1
                                                                    : 0,
                                                          });

                                                          // Update the local state
                                                          setState(() {
                                                            gift.isPledged =
                                                                newPledgeStatus;
                                                          });

                                                          // Show notification based on pledge status
                                                          await NotificationService()
                                                              .showNotification(
                                                            title:
                                                                'Gift Status Change',
                                                            body: newPledgeStatus
                                                                ? '${gift.name} has been pledged by ${user!.displayName}!'
                                                                : '${gift.name} has been un-pledged!',
                                                          );

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              content: Text(
                                                                newPledgeStatus
                                                                    ? 'Gift pledged successfully!'
                                                                    : 'Gift un-pledged successfully!',
                                                              ),
                                                            ),
                                                          );
                                                        } catch (e) {
                                                          // Handle errors
                                                          print(
                                                              "Error updating pledge status: $e");
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              content: Text(
                                                                  'Failed to update pledge status.'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            gift.isPledged
                                                                ? Colors.red
                                                                : Colors.blue,
                                                      ),
                                                      key: ValueKey(
                                                          'pledgingGiftsButton'),
                                                      child: Text(
                                                        gift.isPledged
                                                            ? 'Un-pledge'
                                                            : 'Pledge',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      gift.isPledged
                                                          ? 'Pledged by ${user!.displayName}'
                                                          : 'Available',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: gift.isPledged
                                                            ? Colors.red
                                                            : Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
