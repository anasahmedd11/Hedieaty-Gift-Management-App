import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hedieaty_project/Authentication/AuthUser.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Friends/AddFriendManually.dart';
import 'package:hedieaty_project/Models/User.dart';
import 'package:hedieaty_project/OnBoarding/Login.dart';
import 'package:hedieaty_project/User/AddUserEvent.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../Events/EventList.dart';
import '../Profile/ProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

Widget Badge(int count) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: const BoxDecoration(
      color: Colors.red,
      shape: BoxShape.circle,
    ),
    child: Text(
      '$count',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _HomePageState extends State<HomePage> {
  DataBaseClass mydb = DataBaseClass();
  List<Map<String, dynamic>> retrievedData = [];

  @override
  void initState() {
    super.initState();
    mydb.initialize();
    _loadData();
  }

  void _onSearchChanged(String query) {
    _loadData(query: query);
  }

  void _navigateToEventsPage(Userr friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventListPage(friend: friend),
      ),
    );

    _loadData();
  }

  final myAuth = AuthUser();

  void _showAddFriendOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Add Manually'),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return AddFriend();
                    },
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var scaleTween = Tween(begin: 0.0, end: 1.0)
                          .chain(CurveTween(curve: Curves.easeInOut));
                      var scaleAnimation = animation.drive(scaleTween);
                      return ScaleTransition(
                          scale: scaleAnimation, child: child);
                    },
                    transitionDuration: Duration(milliseconds: 500),
                  ),
                );
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts),
              title: const Text('Add from Contacts'),
              onTap: () {
                pickContact();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadData({String? query}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String loggedInUserID = user.uid;

    String sqlQuery = '''
    SELECT Users.ID, Users.Name, Users.Email, Users.PhoneNumber, Users.ProfilePic, Users.FireStoreID, COUNT(Events.ID) as event_count
    FROM Users LEFT JOIN Events ON Users.ID = Events.UserID
    WHERE Users.LinkedUserID = '$loggedInUserID'
    GROUP BY Users.ID
    ''';

    if (query != null && query.isNotEmpty) {
      sqlQuery = '''
      SELECT Users.ID, Users.Name, Users.Email, Users.PhoneNumber, Users.ProfilePic, Users.FireStoreID, COUNT(Events.ID) as event_count
      FROM Users LEFT JOIN Events ON Users.ID = Events.UserID
      WHERE Users.LinkedUserID = '$loggedInUserID' AND Users.Name LIKE '%$query%'
      GROUP BY Users.ID
      ''';
    }

    var data = await mydb.readData(sqlQuery);

    setState(() {
      retrievedData = data;
    });
  }

  Future<void> addContactToFireStore(Map<String, dynamic> friendData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Friends')
            .add(friendData);

        String firestoreID = docRef.id;
        String updateQuery = '''
          UPDATE Users SET FireStoreID = '$firestoreID'
          WHERE ID = ${friendData['LocalDBID']}
        ''';
        await mydb.updateData(updateQuery);

        await _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error adding contact!')));
      }
    }
  }

  Future<void> addContactToDatabase(Contact contact) async {
    try {
      String name = contact.displayName;
      String email =
          contact.emails.isNotEmpty ? contact.emails.first.address : '';
      String profilePic =
          contact.photo != null ? base64Encode(contact.photo!) : '';
      String phoneNumber =
          contact.phones.isNotEmpty ? contact.phones.first.number : '';

      String insertQuery = '''
      INSERT INTO Users (Name, Email, ProfilePic, PhoneNumber, LinkedUserID)
      VALUES ("$name", "$email", "$profilePic", "$phoneNumber", "${FirebaseAuth.instance.currentUser!.uid}")
      ''';
      int localDBID = await mydb.insertData(insertQuery);

      await addContactToFireStore({
        'Name': name,
        'Email': email,
        'ProfilePic': profilePic,
        'PhoneNumber': phoneNumber,
        'LocalDBID': localDBID,
      });

      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding contact!')));
    }
  }

  Future<void> pickContact() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();

        if (contact != null) {
          await addContactToDatabase(contact);
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Permission denied')));
      }
    } catch (e) {
      print("Error picking contact: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Hedieaty',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: Animate(
                effects: [
                  FadeEffect(
                    begin: 0.0, // Start fully transparent
                    end: 1.0, // Fade to fully opaque
                    duration: 1500.milliseconds,
                  ),
                ],
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AddUserEvent();
                        },
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var tween = Tween(begin: 0.0, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeInOut));
                          var scaleAnimation = animation.drive(tween);

                          return ScaleTransition(
                            scale: scaleAnimation,
                            child: FadeTransition(
                                opacity: animation, child: child),
                          );
                        },
                        transitionDuration: Duration(
                            milliseconds: 500), // Set your custom duration here
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    'Create Your Own Event/List.',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search Friends...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: retrievedData.isEmpty
                ? const Center(
                    child: Text(
                      'No Friends available, start adding some!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: retrievedData.length,
                    itemBuilder: (context, index) {
                      var userPassedData = Userr(
                        name: retrievedData[index]['Name'],
                        email: retrievedData[index]['Email'],
                        ID: retrievedData[index]['ID'],
                        profileImageUrl: retrievedData[index]['ProfilePic'],
                        PhoneNumber:
                            retrievedData[index]['PhoneNumber'].toString(),
                      );
                      int eventCount = retrievedData[index]['event_count'];
                      String? firestoreID = retrievedData[index]['FireStoreID'];
                      return Card(
                        color: Colors.blue,
                        child: ListTile(
                          title: Text(
                            '${retrievedData[index]['Name']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${retrievedData[index]['PhoneNumber']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                '${retrievedData[index]['ProfilePic']}'),
                          ),
                          onTap: () {
                            _navigateToEventsPage(userPassedData);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Badge(eventCount),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                onPressed: () async {
                                  try {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null && firestoreID != null) {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(user.uid)
                                          .collection('Friends')
                                          .doc(firestoreID)
                                          .delete();
                                    }
                                    int response = await mydb.deleteData(
                                        "DELETE FROM Users WHERE ID = ${retrievedData[index]['ID']}");
                                    if (response > 0) {
                                      _loadData();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Friend deleted successfully')),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Failed to delete friend.')),
                                    );
                                  }
                                },
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
      floatingActionButton: Animate(
        effects: [
        ScaleEffect(
          begin: Offset(0.5, 0.5), // Start at half size
          end: Offset(1, 1),   // Grow to full size
          duration: 600.ms,
          curve: Curves.easeInOut,
        ),
        ],
        child: FloatingActionButton(
          onPressed: () {
            _showAddFriendOptions(context);
          },
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.blue,
                    ]),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 18),
                  Text(
                    'Hedieaty',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Animate(
              effects: [
                SlideEffect(
                  begin: Offset(1, 0), // first value represents x, second represents y
                  end: Offset.zero,    // Slide to the original position
                  duration: 400.ms,
                  curve: Curves.easeInOut,
                ),
              ],
              child: ListTile(
                leading: const Icon(
                  Icons.person,
                  size: 26,
                  color: Colors.blue,
                ),
                title: Text(
                  'Profile',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return ProfilePage();
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var offsetTween = Tween(
                            begin: const Offset(1.0, 1.0),
                            end: Offset.zero); // Slide from the right
                        var offsetAnimation = animation.drive(offsetTween);
                        return SlideTransition(
                            position: offsetAnimation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
            ),
            Animate(
              effects: [
                SlideEffect(
                  begin: Offset(1, 0), // first value represents x, second represents y
                  end: Offset.zero,    // Slide to the original position
                  duration: 400.ms,
                  curve: Curves.easeInOut,
                ),
              ],
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  size: 26,
                  color: Colors.blue,
                ),
                title: Text(
                  'Logout',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await myAuth.sign_out();
                  final googleSignIn = GoogleSignIn();
                  googleSignIn.disconnect();
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return LoginScreen();
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var scaleTween = Tween(begin: 0.0, end: 1.0)
                            .chain(CurveTween(curve: Curves.easeInOut));
                        var scaleAnimation = animation.drive(scaleTween);
                        return ScaleTransition(
                            scale: scaleAnimation, child: child);
                      },
                      transitionDuration: Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
