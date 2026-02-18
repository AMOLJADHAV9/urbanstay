import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCollection(String itemType) {
    switch (itemType) {
      case 'room':
        return 'rooms';
      case 'hall':
        return 'function_halls';
      case 'cottage':
        return 'cottages';
      case 'dormitory':
        return 'dormitories';
      default:
        return 'rooms';
    }
  }

  Future<void> createBooking(Booking booking) async {
    // Create the booking
    await _firestore.collection('bookings').add(booking.toMap());

    // Mark item as unavailable with the same status as booking
    final collection = _getCollection(booking.itemType);
    await _firestore.collection(collection).doc(booking.itemId).update({
      'isAvailable': false,
      'status': booking.status,
    });
  }

  Stream<List<Booking>> getBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateStatus(String bookingId, String status) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }

  // Confirm booking
  Future<void> confirmBooking(Booking booking) async {
    await updateStatus(booking.id, 'confirmed');

    final collection = _getCollection(booking.itemType);
    await _firestore.collection(collection).doc(booking.itemId).update({
      'isAvailable': false,
      'status': 'confirmed',
    });
  }

  // Check-in (Start Living)
  Future<void> checkIn(Booking booking) async {
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    await _firestore.collection('bookings').doc(booking.id).update({
      'status': 'living',
      'checkInTime': now,
    });

    final collection = _getCollection(booking.itemType);
    await _firestore.collection(collection).doc(booking.itemId).update({
      'status': 'living',
    });
  }

  // Check-out
  Future<void> checkout(Booking booking) async {
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    await _firestore.collection('bookings').doc(booking.id).update({
      'status': 'checked_out',
      'checkOutTime': now,
    });

    final collection = _getCollection(booking.itemType);
    await _firestore.collection(collection).doc(booking.itemId).update({
      'isAvailable': true,
      'status': 'available',
    });
  }

  Future<void> markAvailable(Booking booking) async {
    await checkout(booking);
  }

  // Reject booking
  Future<void> rejectBooking(Booking booking) async {
    await updateStatus(booking.id, 'rejected');

    final collection = _getCollection(booking.itemType);
    await _firestore.collection(collection).doc(booking.itemId).update({
      'isAvailable': true,
      'status': 'available',
    });
  }
}
