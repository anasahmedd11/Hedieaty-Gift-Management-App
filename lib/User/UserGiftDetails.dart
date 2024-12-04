import 'package:flutter/material.dart';
import '../Models/Gift.dart';

class UserGiftDetailsPage extends StatelessWidget {
  final Gift gift;

  const UserGiftDetailsPage({required this.gift, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            gift.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 100)),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                        // Drag handle
                        child: Container(
                          height: 5,
                          width: 50,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        gift.name,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      Text("Category:", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      const SizedBox(height: 4),
                      Text("${gift.category}",style: TextStyle(fontSize: 17)),

                      const SizedBox(height: 10),
                      Text("Price:", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      const SizedBox(height: 4),
                      Text("\$${gift.Price.toString()}",style: TextStyle(fontSize: 17)),

                      const SizedBox(height: 10),
                      Text("Description:", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      const SizedBox(height: 4),
                      Text("${gift.Description}",style: TextStyle(fontSize: 17),maxLines: 2,textAlign: TextAlign.center),

                      const SizedBox(height: 10),
                      Text("Status:", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      Text("${gift.isPledged ? 'Pledged' : 'Available'}",style: TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
