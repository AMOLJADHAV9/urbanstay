import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/booking_service.dart';
import 'models/booking_model.dart';

class CustomerBookingsScreen extends StatelessWidget {
  const CustomerBookingsScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'living':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'checked_out':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
      ),
      body: StreamBuilder<List<Booking>>(
        stream: bookingService.getBookings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final myBookings = snapshot.data!
              .where((booking) => booking.userId == user?.uid)
              .toList();

          if (myBookings.isEmpty) {
            return const Center(
              child: Text("No bookings yet"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: myBookings.length,
            itemBuilder: (context, index) {
              final booking = myBookings[index];

              return FutureBuilder<DocumentSnapshot>(
                future: booking.itemType == 'room'
                    ? FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(booking.itemId)
                        .get()
                    : FirebaseFirestore.instance
                        .collection('function_halls')
                        .doc(booking.itemId)
                        .get(),
                builder: (context, itemSnapshot) {
                  String roomNumber = '-';
                  String roomType = '-';
                  String price = '-';

                  if (itemSnapshot.hasData && itemSnapshot.data!.exists) {
                    final data =
                        itemSnapshot.data!.data() as Map<String, dynamic>;
                    if (booking.itemType == 'room') {
                      roomNumber = data['roomNumber']?.toString() ?? '-';
                      roomType = data['type'] ?? '-';
                      price = '₹ ${data['price'] ?? '-'}';
                    } else {
                      roomNumber =
                          'Hall ${data['hallNumber']?.toString() ?? '-'}';
                      roomType = data['type'] ?? '-';
                      price = '₹ ${data['price'] ?? '-'}';
                    }
                  }

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
                          // Header: Booking Type + Status
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    booking.itemType == 'room'
                                        ? Icons.hotel
                                        : Icons.meeting_room,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${booking.itemType.toUpperCase()} Booking",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(booking.status)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  booking.status.toUpperCase().replaceAll('_', ' '),
                                  style: TextStyle(
                                    color: _statusColor(booking.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Room / Hall Details
                          _detailRow("Room / Hall No", roomNumber),
                          _detailRow("Type", roomType),
                          _detailRow("Rent", price),
                          _detailRow("Booking Date", booking.date),

                          const Divider(height: 20),

                          // Customer Details
                          _detailRow("Name", booking.userName),
                          
                          // History Details
                          if (booking.checkInTime != null)
                            _detailRow("Check-in Time", booking.checkInTime!, color: Colors.purple),
                          if (booking.checkOutTime != null)
                            _detailRow("Check-out Time", booking.checkOutTime!, color: Colors.blue),

                          const SizedBox(height: 15),

                          // Action Buttons
                          if (booking.status == 'confirmed')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.login),
                                label: const Text("Check-in (Start Living)"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Confirm Check-in"),
                                      content: const Text("Clicking confirm will start your stay. A record will be saved in your history."),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await bookingService.checkIn(booking);
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Confirm Check-in"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                          if (booking.status == 'living')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.exit_to_app),
                                label: const Text("Check-out Now"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Confirm Check-out"),
                                      content: const Text("Are you sure you want to check out? This will make the room/hall available for others."),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await bookingService.checkout(booking);
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Confirm Check-out"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
