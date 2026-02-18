class FunctionHall {
  final String id;
  final int hallNumber;
  final String type;
  final double price;
  final int capacity;
  final String description;
  final String status; // available, pending, confirmed

  FunctionHall({
    required this.id,
    required this.hallNumber,
    required this.type,
    required this.price,
    required this.capacity,
    required this.description,
    required this.status,
  });

  factory FunctionHall.fromMap(String id, Map<String, dynamic> data) {
    return FunctionHall(
      id: id,
      hallNumber: data['hallNumber'] ?? 0,
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      capacity: data['capacity'] ?? 0,
      description: data['description'] ?? '',
      status: data['status'] ?? (data['isAvailable'] == false ? 'confirmed' : 'available'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hallNumber': hallNumber,
      'type': type,
      'price': price,
      'capacity': capacity,
      'description': description,
      'status': status,
      'isAvailable': status == 'available',
      'createdAt': DateTime.now(),
    };
  }
}
