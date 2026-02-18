import 'package:flutter/material.dart';
import 'models/function_hall_model.dart';
import 'services/function_hall_service.dart';
import 'hall_booking_screen.dart';

class CustomerHallsScreen extends StatelessWidget {
  const CustomerHallsScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hallService = FunctionHallService();

    return Scaffold(
      appBar: AppBar(title: const Text("Available Function Halls")),
      body: StreamBuilder<List<FunctionHall>>(
        stream: hallService.getHalls(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show halls that are NOT confirmed (Available or Pending)
          final halls = snapshot.data!
              .where((hall) => hall.status != 'confirmed')
              .toList();

          if (halls.isEmpty) {
            return const Center(
              child: Text("No function halls available"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: halls.length,
            itemBuilder: (context, index) {
              final hall = halls[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.meeting_room,
                              size: 36, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hall ${hall.hallNumber} - ${hall.type}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    "Capacity: ${hall.capacity} people"),
                                Row(
                                  children: [
                                    Text(
                                      "₹ ${hall.price}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _statusColor(hall.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: _statusColor(hall.status)),
                                      ),
                                      child: Text(
                                        hall.status.toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(hall.status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (hall.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          hall.description,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: hall.status == 'available' 
                        ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HallBookingScreen(hall: hall),
                              ),
                            );
                          },
                          child: const Text("Book Now"),
                        )
                        : const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "CURRENTLY PENDING - WAIT LIST",
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
