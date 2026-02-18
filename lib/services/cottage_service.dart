import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cottage_model.dart';

class CottageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new cottage
  Future<void> addCottage(Cottage cottage) async {
    await _firestore.collection('cottages').add(cottage.toMap());
  }

  // Get all cottages
  Stream<List<Cottage>> getCottages() {
    return _firestore.collection('cottages').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Cottage.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Delete a cottage
  Future<void> deleteCottage(String cottageId) async {
    await _firestore.collection('cottages').doc(cottageId).delete();
  }

  // Update status
  Future<void> updateStatus(String cottageId, String status) async {
    await _firestore.collection('cottages').doc(cottageId).update({
      'status': status,
      'isAvailable': status == 'available',
    });
  }
}
