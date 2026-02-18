import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/dormitory_service.dart';
import 'models/dormitory_model.dart';
import 'dormitory_booking_screen.dart';

class CustomerDormitoryScreen extends StatelessWidget {
  const CustomerDormitoryScreen({super.key});

  Color _statusColor(String status) {
    if (status == 'pending') return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final dormitoryService = DormitoryService();

    return Scaffold(
      appBar: AppBar(title: const Text("Available Dormitory Halls")),
      body: StreamBuilder<List<Dormitory>>(
        stream: dormitoryService.getDormitories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show dormitories that are NOT confirmed or living (Available or Pending)
          final dorms = snapshot.data!
              .where((d) => d.status != 'confirmed' && d.status != 'living')
              .toList();

          if (dorms.isEmpty) {
            return const Center(child: Text("No dormitory halls available"));
          }

          return ListView.builder(
            itemCount: dorms.length,
            itemBuilder: (context, index) {
              final dorm = dorms[index];
              final isPending = dorm.status == 'pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.apartment,
                          color: Colors.blue, size: 40),
                      title: Text(
                        "Dormitory Hall ${dorm.dormitoryNumber}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${dorm.type} - Capacity: ${dorm.capacity}"),
                      trailing: Text(
                        "₹ ${dorm.price}\n/day",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (dorm.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(dorm.description,
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                              color: _statusColor(dorm.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dorm.status.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(dorm.status),
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
                                            DormitoryBookingScreen(
                                                dormitory: dorm),
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
