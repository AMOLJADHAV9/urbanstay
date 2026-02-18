import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'models/room_model.dart';
import 'models/booking_model.dart';
import 'services/booking_service.dart';

class RoomBookingScreen extends StatefulWidget {
  final Room room;

  const RoomBookingScreen({super.key, required this.room});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  late Razorpay _razorpay;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController idProofController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String selectedIdProofType = 'Aadhaar ID';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    nameController.text = user?.displayName ?? '';
    emailController.text = user?.email ?? '';

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    idProofController.dispose();
    addressController.dispose();
    dateController.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment successful, now create the confirmed booking
    _finishBooking('confirmed');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      dateController.text =
          "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void startPayment() {
    if (!_formKey.currentState!.validate()) return;
    if (dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a booking date")),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_S6rSdArYDhTpvx',
      'amount': (widget.room.price * 100).toInt(), // amount in the smallest currency unit (paise)
      'name': 'UrbanStay',
      'description': 'Booking for Room ${widget.room.roomNumber}',
      'timeout': 300, // in seconds
      'prefill': {
        'contact': contactController.text.trim(),
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay: $e");
    }
  }

  Future<void> _finishBooking(String status) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final booking = Booking(
        id: '',
        userId: user?.uid ?? '',
        userName: nameController.text.trim(),
        email: emailController.text.trim(),
        contactNumber: contactController.text.trim(),
        idProofType: selectedIdProofType,
        idProofNumber: idProofController.text.trim(),
        permanentAddress: addressController.text.trim(),
        itemId: widget.room.id,
        itemType: 'room',
        date: dateController.text.trim(),
        status: status, // This will be 'confirmed' after payment
      );

      await _bookingService.createBooking(booking);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful! Booking Confirmed."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving booking: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Room ${widget.room.roomNumber}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Info Card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.hotel, size: 40, color: Colors.blue),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Room ${widget.room.roomNumber}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Type: ${widget.room.type}"),
                          Text(
                            "₹ ${widget.room.price} / night",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Customer Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Full Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 15),

              // Email
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email ID",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your email" : null,
              ),
              const SizedBox(height: 15),

              // Contact Number
              TextFormField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Contact Number",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter contact number" : null,
              ),
              const SizedBox(height: 15),

              // ID Proof Type
              DropdownButtonFormField<String>(
                value: selectedIdProofType,
                decoration: const InputDecoration(
                  labelText: "ID Proof Type",
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Aadhaar ID',
                    child: Text("Aadhaar ID"),
                  ),
                  DropdownMenuItem(
                    value: 'Voter ID',
                    child: Text("Voter ID"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedIdProofType = value!;
                  });
                },
              ),
              const SizedBox(height: 15),

              // ID Proof Number
              TextFormField(
                controller: idProofController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "$selectedIdProofType Number",
                  prefixIcon: const Icon(Icons.credit_card),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter ID proof number" : null,
              ),
              const SizedBox(height: 15),

              // Permanent Address
              TextFormField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Permanent Address",
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your address" : null,
              ),
              const SizedBox(height: 15),

              // Booking Date
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Booking Date",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: _selectDate,
                validator: (value) =>
                    value!.isEmpty ? "Select a date" : null,
              ),
              const SizedBox(height: 25),

              // Pay and Book Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: Text(
                    "Pay ₹${widget.room.price} & Book Now",
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: startPayment,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
