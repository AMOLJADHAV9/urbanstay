class Room {
  final String id;
  final int roomNumber;
  final String type;
  final double price;
  final String status; // available, pending, confirmed

  Room({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.price,
    required this.status,
  });

  factory Room.fromMap(String id, Map<String, dynamic> data) {
    return Room(
      id: id,
      roomNumber: data['roomNumber'] ?? 0,
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: data['status'] ?? (data['isAvailable'] == false ? 'confirmed' : 'available'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'type': type,
      'price': price,
      'status': status,
      'isAvailable': status == 'available', // Keep for backward compatibility if needed
    };
  }
}
