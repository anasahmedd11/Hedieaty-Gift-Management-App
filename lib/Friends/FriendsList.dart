import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hedieaty_project/Authentication/AuthUser.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Events/EventList.dart';
import 'package:hedieaty_project/Models/User.dart';
import 'package:hedieaty_project/Profile/ProfilePage.dart';
import 'package:hedieaty_project/User/AddUserEvent.dart';

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
  final myAuth = AuthUser();
  List<Map<String, dynamic>> retrievedData = [];

  @override
  void initState() {
    super.initState();
    mydb.initialize();
    _loadData();
  }

  Future<void> _loadData({String? query}) async {
    setState(() {});
    String sqlQuery =
        "SELECT Users.ID, Users.Name, Users.Email, Users.PhoneNumber,Users.ProfilePic, COUNT(Events.ID) as event_count "
        "FROM Users LEFT JOIN Events ON Users.ID = Events.UserID "
        "GROUP BY Users.ID";
    if (query != null && query.isNotEmpty) {
      sqlQuery =
      "SELECT Users.ID, Users.Name, Users.Email, Users.PhoneNumber,Users.ProfilePic, COUNT(Events.ID) as event_count "
          "FROM Users LEFT JOIN Events ON Users.ID = Events.UserID "
          "WHERE Users.Name LIKE '%$query%' "
          "GROUP BY Users.ID";
    }
    var data = await mydb.readData(sqlQuery);
    setState(() {
      retrievedData = data;
    });
  }

  // Method to handle the search input
  void _onSearchChanged(String query) {
    _loadData(query: query);
  }

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
                  Navigator.pushNamed(context, '/Add');
                  _loadData();
                }),
            ListTile(
              leading: const Icon(Icons.contacts),
              title: const Text('Add from Contacts'),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void _navigateToEventsPage(User friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventListPage(friend: friend),
      ),
    );
    _loadData();
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
            onPressed: () {
              setState(() {
                _loadData();
              });
            },
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddUserEvent(),
                      ));
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
                  var userPassedData = User(
                    name: retrievedData[index]['Name'],
                    email: retrievedData[index]['Email'],
                    ID: retrievedData[index]['ID'],
                    profileImageUrl: retrievedData[index]['ProfilePic'],
                    PhoneNumber:
                    retrievedData[index]['PhoneNumber'].toString(),
                  );
                  int eventCount = retrievedData[index]['event_count'];

                  return Card(
                    color: Colors.blue,
                    child: ListTile(
                      title: Text('${retrievedData[index]['Name']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${retrievedData[index]['PhoneNumber']?.toString()}',
                          style: const TextStyle(color: Colors.white)),
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
                            icon: const Icon(Icons.delete,color: Colors.white,),
                            onPressed: () async {
                              int response = await mydb.deleteData(
                                  "DELETE FROM Users WHERE ID= ${retrievedData[index]['ID']}");
                              if (response > 0) {
                                _loadData();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFriendOptions(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.person_add,
          color: Colors.white,
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
            ListTile(
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
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
                Navigator.pushReplacementNamed(
                  context,
                  '/Sign_in',
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
