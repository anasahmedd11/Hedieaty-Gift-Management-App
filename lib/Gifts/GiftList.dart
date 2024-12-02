// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:hedieaty_project/Database/DatabaseClass.dart';
// import 'package:hedieaty_project/Gifts/AddGift.dart';
// import 'package:hedieaty_project/Gifts/EditGift.dart';
// import 'package:hedieaty_project/Gifts/GiftDetails.dart';
// import 'package:hedieaty_project/Gifts/PledgedGiftsList.dart';
// import 'package:hedieaty_project/Models/Event.dart';
// import 'package:hedieaty_project/Models/Gift.dart';
// import 'package:transparent_image/transparent_image.dart';
//
//
// class GiftListPage extends StatefulWidget {
//   final Events event;
//
//   const GiftListPage({required this.event, super.key});
//
//   @override
//   _GiftListPageState createState() => _GiftListPageState();
// }
//
// class _GiftListPageState extends State<GiftListPage> {
//   DataBaseClass mydb = DataBaseClass();
//   List<Map<String, dynamic>> giftData = [];
//   List<Gift> pledgedGifts = [];
//
//   String _sortField = 'name'; // Default sort by name
//   bool _sortAscending = true; // Default to ascending order
//
//   @override
//   void initState() {
//     super.initState();
//     _loadGifts();
//   }
//
//   Future<void> _loadGifts() async {
//     String sqlQuery = "SELECT * FROM Gifts WHERE EventID = ${widget.event.ID}";
//     var data = await mydb.readData(sqlQuery);
//     setState(() {
//       giftData = data;
//     });
//   }
//
//   void _sortGifts(String field) {
//     if (_sortField == field) {
//       setState(() {
//         _sortAscending = !_sortAscending;
//       });
//     } else {
//       setState(() {
//         _sortField = field;
//         _sortAscending = true; // Reset to ascending when a new field is selected
//       });
//     }
//   }
//
//   List<Map<String, dynamic>> getSortedGifts() {
//     List<Map<String, dynamic>> sortedGifts = List<Map<String, dynamic>>.from(giftData);
//
//     sortedGifts.sort((a, b) {
//       if (_sortField == 'name') {
//         return _sortAscending ? a['Name'].compareTo(b['Name']) : b['Name'].compareTo(a['Name']);
//       } else if (_sortField == 'category') {
//         return _sortAscending ? a['Category'].compareTo(b['Category']) : b['Category'].compareTo(a['Category']);
//       } else if (_sortField == 'price') {
//         return _sortAscending ? a['Price'].compareTo(b['Price']) : b['Price'].compareTo(a['Price']);
//       }
//       return 0;
//     });
//
//     return sortedGifts;
//   }
//
//   void _togglePledge(Gift gift) async {
//     bool newPledgeStatus = !gift.isPledged;
//
//     int response = await mydb.updateData("UPDATE Gifts SET isPledged = ${newPledgeStatus ? 1 : 0} WHERE ID = ${gift.ID}");
//
//     if (response > 0) {
//       setState(() {
//         gift.isPledged = newPledgeStatus;
//
//         if (gift.isPledged) {
//           pledgedGifts.add(gift);
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gift Pledged')));
//         } else {
//           pledgedGifts.removeWhere((pledgedGift) => pledgedGift.ID == gift.ID);
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gift Unpledged')));
//         }
//       });
//
//       _loadGifts();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Map<String, dynamic>> sortedGifts = getSortedGifts();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.event.name} Gifts', style: const TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           PopupMenuButton<String>(
//             iconColor: Colors.white,
//             onSelected: (value) {
//               _sortGifts(value);
//             },
//             itemBuilder: (context) {
//               return const [
//                 PopupMenuItem<String>(
//                   value: 'name',
//                   child: Text('Sort by Name'),
//                 ),
//                 PopupMenuItem<String>(
//                   value: 'category',
//                   child: Text('Sort by Category'),
//                 ),
//                 PopupMenuItem<String>(
//                   value: 'price',
//                   child: Text('Sort by Price'),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       body: giftData.isEmpty
//           ? const Center(
//         child: Text(
//           'No gifts added yet!',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//       )
//           : Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//               onPressed: () {
//                 Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => PledgedGiftsPage(eventId: widget.event.ID),
//                 ));
//               },
//               child: const Text(
//                 "View Pledged Gifts",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.all(10),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 1,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 3 / 2,
//               ),
//               itemCount: sortedGifts.length,
//               itemBuilder: (context, index) {
//                 var gift = Gift(
//                   name: sortedGifts[index]['Name'],
//                   Price: sortedGifts[index]['Price'],
//                   category: sortedGifts[index]['Category'],
//                   Description: sortedGifts[index]['Description'],
//                   imageUrl: sortedGifts[index]['GiftPic'],
//                   ID: sortedGifts[index]['ID'],
//                   isPledged: sortedGifts[index]['isPledged'] == 1,
//                 );
//
//                 return Card(
//                   margin: const EdgeInsets.all(10),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
//                   clipBehavior: Clip.hardEdge,
//                   elevation: 2,
//                   child: Stack(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                               builder: (context) => GiftDetailsPage(giftId: sortedGifts[index]['ID'])));
//                         },
//                         child: BackdropFilter(
//                           filter: gift.isPledged ? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0) : ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
//                           child: FadeInImage(
//                             placeholder: MemoryImage(kTransparentImage),
//                             image: NetworkImage(gift.imageUrl),
//                             fit: BoxFit.fill,
//                             width: double.infinity,
//                             height: 250,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         left: 0,
//                         right: 0,
//                         child: Container(
//                           color: Colors.black87,
//                           child: Column(
//                             children: [
//                               Text(
//                                 gift.name,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 7),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     GestureDetector(
//                                       onTap: gift.isPledged
//                                           ? null
//                                           : () async {
//                                         int response = await mydb.deleteData("DELETE FROM Gifts WHERE ID= ${sortedGifts[index]['ID']}");
//                                         if (response > 0) {
//                                           _loadGifts();
//                                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gift Deleted')));
//                                         }
//                                       },
//                                       child: Icon(
//                                         Icons.delete,
//                                         color: gift.isPledged ?  Colors.grey : Colors.blue,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     GestureDetector(
//                                       onTap: gift.isPledged
//                                           ? null
//                                           : () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) => EditGiftPage(gift: gift, onGiftUpdated: _loadGifts)));
//                                       },
//                                       child: Icon(
//                                         Icons.edit,
//                                         color: gift.isPledged ?  Colors.grey : Colors.blue,
//                                       ),
//                                     ),
//                                     const Spacer(),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         _togglePledge(gift);
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: gift.isPledged ? Colors.red : Colors.blue,
//                                       ),
//                                       child: Text(
//                                         gift.isPledged ? 'Un-pledge' : 'Pledge',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => NewGift(event: widget.event),
//               ));
//         },
//         backgroundColor: Colors.blue,
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
