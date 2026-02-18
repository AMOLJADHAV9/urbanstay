import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/cottage_service.dart';
import 'models/cottage_model.dart';
import 'cottage_booking_screen.dart';

class CustomerCottagesScreen extends StatelessWidget {
  const CustomerCottagesScreen({super.key});

  Color _statusColor(String status) {
    if (status == 'pending') return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final cottageService = CottageService();

    return Scaffold(
      appBar: AppBar(title: const Text("Available Cottages")),
      body: StreamBuilder<List<Cottage>>(
        stream: cottageService.getCottages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show cottages that are NOT confirmed or living (Available or Pending)
          final cottages = snapshot.data!
              .where((c) => c.status != 'confirmed' && c.status != 'living')
              .toList();

          if (cottages.isEmpty) {
            return const Center(child: Text("No cottages available right now"));
          }

          return ListView.builder(
            itemCount: cottages.length,
            itemBuilder: (context, index) {
              final cottage = cottages[index];
              final isPending = cottage.status == 'pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_work,
                          color: Colors.blue, size: 40),
                      title: Text(
                        "Cottage ${cottage.cottageNumber}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(cottage.type),
                      trailing: Text(
                        "₹ ${cottage.price}\n/night",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _statusColor(cottage.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cottage.status.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(cottage.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isPending
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CottageBookingScreen(
                                                cottage: cottage),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isPending ? Colors.grey : Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isPending ? "WAIT LIST" : "Book Now"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
