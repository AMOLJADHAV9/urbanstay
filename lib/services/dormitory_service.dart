import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dormitory_model.dart';

class DormitoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new dormitory hall
  Future<void> addDormitory(Dormitory dormitory) async {
    await _firestore.collection('dormitories').add(dormitory.toMap());
  }

  // Get all dormitories
  Stream<List<Dormitory>> getDormitories() {
    return _firestore.collection('dormitories').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Dormitory.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Delete a dormitory
  Future<void> deleteDormitory(String dormitoryId) async {
    await _firestore.collection('dormitories').doc(dormitoryId).delete();
  }

  // Update status
  Future<void> updateStatus(String dormitoryId, String status) async {
    await _firestore.collection('dormitories').doc(dormitoryId).update({
      'status': status,
      'isAvailable': status == 'available',
    });
  }
}
