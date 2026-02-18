import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'models/function_hall_model.dart';
import 'models/booking_model.dart';
import 'services/booking_service.dart';

class HallBookingScreen extends StatefulWidget {
  final FunctionHall hall;

  const HallBookingScreen({super.key, required this.hall});

  @override
  State<HallBookingScreen> createState() => _HallBookingScreenState();
}

class _HallBookingScreenState extends State<HallBookingScreen> {
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
        const SnackBar(content: Text("Please select an event date")),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_S6rSdArYDhTpvx',
      'amount': (widget.hall.price * 100).toInt(),
      'name': 'UrbanStay',
      'description': 'Booking for Hall ${widget.hall.hallNumber}',
      'timeout': 300,
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
        itemId: widget.hall.id,
        itemType: 'hall',
        date: dateController.text.trim(),
        status: status,
      );

      await _bookingService.createBooking(booking);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful! Hall Booking Confirmed."),
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
        title: Text("Book Hall ${widget.hall.hallNumber}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hall Info Card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.meeting_room,
                          size: 40, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hall ${widget.hall.hallNumber}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Type: ${widget.hall.type}"),
                            Text("Capacity: ${widget.hall.capacity}"),
                            Text(
                              "₹ ${widget.hall.price}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.hall.description.isNotEmpty)
                              Text(
                                widget.hall.description,
                                style: const TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
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

              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Event Date",
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
                    "Pay ₹${widget.hall.price} & Book Now",
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
