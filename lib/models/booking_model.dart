class Booking {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final String contactNumber;
  final String idProofType; // aadhaar or voter
  final String idProofNumber;
  final String permanentAddress;
  final String itemId;
  final String itemType; // room or hall
  final String date;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.contactNumber,
    required this.idProofType,
    required this.idProofNumber,
    required this.permanentAddress,
    required this.itemId,
    required this.itemType,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'contactNumber': contactNumber,
      'idProofType': idProofType,
      'idProofNumber': idProofNumber,
      'permanentAddress': permanentAddress,
      'itemId': itemId,
      'itemType': itemType,
      'date': date,
      'status': status,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'createdAt': DateTime.now(),
    };
  }

  factory Booking.fromMap(String id, Map<String, dynamic> data) {
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      idProofType: data['idProofType'] ?? '',
      idProofNumber: data['idProofNumber'] ?? '',
      permanentAddress: data['permanentAddress'] ?? '',
      itemId: data['itemId'] ?? '',
      itemType: data['itemType'] ?? '',
      date: data['date'] ?? '',
      status: data['status'] ?? '',
      checkInTime: data['checkInTime'],
      checkOutTime: data['checkOutTime'],
    );
  }
}
