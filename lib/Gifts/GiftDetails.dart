import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';

class GiftDetailsPage extends StatefulWidget {
  final int giftId;

  const GiftDetailsPage({required this.giftId, Key? key}) : super(key: key);

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  DataBaseClass mydb = DataBaseClass();
  Map<String, dynamic>? giftDetails;

  @override
  void initState() {
    super.initState();
    _loadGiftDetails();
  }

  Future<void> _loadGiftDetails() async {
    String query = "SELECT * FROM Gifts WHERE ID = ${widget.giftId}";
    var data = await mydb.readData(query);

    if (data.isNotEmpty) {
      setState(() {
        giftDetails = data.first; // Assuming only one record is fetched
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(giftDetails?['Name'],style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: giftDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              giftDetails!['GiftPic'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 100)),
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
                          giftDetails!['Name'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailSection("Category",
                            giftDetails!['Category']),
                        _buildDetailSection(
                            "Price", "${giftDetails!['Price']}"),
                        _buildDetailSection(
                            "Description",
                            giftDetails!['Description'] ??
                                "No description"),
                        _buildDetailSection(
                            "Status",
                            giftDetails!['isPledged'] == 1
                                ? "Pledged"
                                : "Available"),
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

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$title:",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Center(
            child: Text(
              textAlign: TextAlign.center,
              value,
              maxLines: 2,
              style: const TextStyle(fontSize: 19),
            ),
          ),
        ],
      ),
    );
  }
}
