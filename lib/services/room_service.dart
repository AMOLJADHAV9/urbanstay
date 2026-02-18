import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create room
  Future<void> createRoom(Room room) async {
    await _firestore.collection('rooms').add(room.toMap());
  }

  // Get all rooms
  Stream<List<Room>> getRooms() {
    return _firestore.collection('rooms').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Room.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Update status
  Future<void> updateStatus(String roomId, String status) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'status': status,
      'isAvailable': status == 'available',
    });
  }

  // Delete room
  Future<void> deleteRoom(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).delete();
  }
}
