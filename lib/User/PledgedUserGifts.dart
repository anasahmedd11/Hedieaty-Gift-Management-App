import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Models/Gift.dart';

class PledgedUserGifts extends StatefulWidget {
  const PledgedUserGifts({required this.eventId, super.key});

  final int eventId;

  @override
  State<PledgedUserGifts> createState() => _PledgedUserGiftsState();
}

class _PledgedUserGiftsState extends State<PledgedUserGifts> {
  List<Map<String, dynamic>> pledgedGiftData = [];
  final mydb = DataBaseClass();

  Future<void> _loadGifts() async {
    String sqlQuery =
        "SELECT * FROM Gifts WHERE isPledged = 1 AND EventID = ${widget.eventId}";
    var data = await mydb.readData(sqlQuery);
    setState(() {
      pledgedGiftData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Pledged Gifts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: pledgedGiftData.isEmpty
          ? const Center(
        child: Text(
          'No gifts pledged yet!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: pledgedGiftData.length,
        itemBuilder: (context, index) {
          var gift = Gift(
            name: pledgedGiftData[index]['Name'],
            Price: pledgedGiftData[index]['Price'],
            category: pledgedGiftData[index]['Category'],
            Description: pledgedGiftData[index]['Description'],
            imageUrl: pledgedGiftData[index]['GiftPic'],
            ID: pledgedGiftData[index]['ID'],
            isPledged: pledgedGiftData[index]['isPledged'] == 1,
          );

          return Padding(
            padding: const EdgeInsets.all(10.0),
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
                    gift.name,
                    maxLines: 1,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${gift.category} - ${gift.Price}',
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
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
