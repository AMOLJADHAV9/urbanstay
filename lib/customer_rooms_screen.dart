import 'package:flutter/material.dart';
import 'services/room_service.dart';
import 'models/room_model.dart';
import 'room_booking_screen.dart';

class CustomerRoomsScreen extends StatelessWidget {
  const CustomerRoomsScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
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
    final roomService = RoomService();

    return Scaffold(
      appBar: AppBar(title: const Text("Available Rooms")),
      body: StreamBuilder<List<Room>>(
        stream: roomService.getRooms(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show rooms that are NOT confirmed (Available or Pending)
          final rooms = snapshot.data!
              .where((room) => room.status != 'confirmed')
              .toList();

          if (rooms.isEmpty) {
            return const Center(
              child: Text("No rooms available"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.hotel, size: 36, color: Colors.blue),
                  title: Text(
                    "Room ${room.roomNumber} - ${room.type}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₹ ${room.price} / night"),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(room.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _statusColor(room.status)),
                        ),
                        child: Text(
                          room.status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(room.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: room.status == 'available'
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoomBookingScreen(room: room),
                              ),
                            );
                          },
                          child: const Text("Book Now"),
                        )
                      : const Text(
                          "WAIT LIST",
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
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
