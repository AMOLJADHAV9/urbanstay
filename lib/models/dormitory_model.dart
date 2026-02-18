class Dormitory {
  final String id;
  final int dormitoryNumber;
  final String type;
  final double price;
  final int capacity;
  final String description;
  final String status; // available, pending, confirmed, living

  Dormitory({
    required this.id,
    required this.dormitoryNumber,
    required this.type,
    required this.price,
    required this.capacity,
    required this.description,
    required this.status,
  });

  factory Dormitory.fromMap(String id, Map<String, dynamic> data) {
    return Dormitory(
      id: id,
      dormitoryNumber: data['dormitoryNumber'] ?? 0,
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      capacity: data['capacity'] ?? 0,
      description: data['description'] ?? '',
      status: data['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dormitoryNumber': dormitoryNumber,
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
