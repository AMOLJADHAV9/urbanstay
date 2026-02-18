import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/function_hall_model.dart';

class FunctionHallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createHall(FunctionHall hall) async {
    await _firestore.collection('function_halls').add(hall.toMap());
  }

  Stream<List<FunctionHall>> getHalls() {
    return _firestore
        .collection('function_halls')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FunctionHall.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateStatus(String hallId, String status) async {
    await _firestore
        .collection('function_halls')
        .doc(hallId)
        .update({
          'status': status,
          'isAvailable': status == 'available',
        });
  }

  Future<void> deleteHall(String hallId) async {
    await _firestore.collection('function_halls').doc(hallId).delete();
  }
}
