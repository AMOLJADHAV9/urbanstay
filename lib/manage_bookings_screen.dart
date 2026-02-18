import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/booking_service.dart';
import 'models/booking_model.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

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
      case 'available':
      case 'checked_out':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Bookings")),
      body: StreamBuilder<List<Booking>>(
        stream: bookingService.getBookings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

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
                  String itemNumber = '-';
                  String itemType = '-';
                  String price = '-';

                  if (itemSnapshot.hasData &&
                      itemSnapshot.data!.exists) {
                    final data = itemSnapshot.data!.data()
                        as Map<String, dynamic>;
                    if (booking.itemType == 'room') {
                      itemNumber =
                          'Room ${data['roomNumber']?.toString() ?? '-'}';
                      itemType = data['type'] ?? '-';
                      price = '₹ ${data['price'] ?? '-'}';
                    } else {
                      itemNumber =
                          'Hall ${data['hallNumber']?.toString() ?? '-'}';
                      itemType = data['type'] ?? '-';
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
                          // Header
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
                                    color:
                                        _statusColor(booking.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Item Details
                          _detailRow("Item", itemNumber),
                          _detailRow("Type", itemType),
                          _detailRow("Rent", price),
                          _detailRow("Date", booking.date),

                          const Divider(height: 20),

                          // Timeline History
                          if (booking.checkInTime != null)
                            _detailRow("Check-in", booking.checkInTime!, color: Colors.purple),
                          if (booking.checkOutTime != null)
                            _detailRow("Check-out", booking.checkOutTime!, color: Colors.blue),
                          
                          if (booking.checkInTime != null || booking.checkOutTime != null)
                            const Divider(height: 20),

                          // Customer Details
                          _detailRow("Customer", booking.userName),
                          _detailRow("Email", booking.email),
                          _detailRow("Contact",
                              booking.contactNumber),
                          _detailRow("ID Proof",
                              "${booking.idProofType}: ${booking.idProofNumber}"),
                          _detailRow(
                              "Address", booking.permanentAddress),

                          const SizedBox(height: 12),

                          // Action Buttons based on status
                          _buildActions(
                              context, booking, bookingService),
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

  Widget _buildActions(BuildContext context, Booking booking,
      BookingService bookingService) {
    if (booking.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                bookingService.confirmBooking(booking);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Booking Confirmed")),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text("Reject"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                bookingService.rejectBooking(booking);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          "Booking Rejected. Room/Hall is now available.")),
                );
              },
            ),
          ),
        ],
      );
    } else if (booking.status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login, color: Colors.white),
          label: const Text("Record Check-in (Manual)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            bookingService.checkIn(booking);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      "Staff recorded customer check-in.")),
            );
          },
        ),
      );
    } else if (booking.status == 'living') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          label: const Text("Record Check-out (Manual)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            bookingService.checkout(booking);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      "Staff recorded customer check-out.")),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
