class Cottage {
  final String id;
  final int cottageNumber;
  final String type;
  final double price;
  final String status; // available, pending, confirmed, living

  Cottage({
    required this.id,
    required this.cottageNumber,
    required this.type,
    required this.price,
    required this.status,
  });

  factory Cottage.fromMap(String id, Map<String, dynamic> data) {
    return Cottage(
      id: id,
      cottageNumber: data['cottageNumber'] ?? 0,
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: data['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cottageNumber': cottageNumber,
      'type': type,
      'price': price,
      'status': status,
      'isAvailable': status == 'available',
      'createdAt': DateTime.now(),
    };
  }
}
