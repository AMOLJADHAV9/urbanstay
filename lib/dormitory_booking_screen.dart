import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'services/booking_service.dart';
import 'models/booking_model.dart';
import 'models/dormitory_model.dart';

class DormitoryBookingScreen extends StatefulWidget {
  final Dormitory dormitory;
  const DormitoryBookingScreen({super.key, required this.dormitory});

  @override
  State<DormitoryBookingScreen> createState() => _DormitoryBookingScreenState();
}

class _DormitoryBookingScreenState extends State<DormitoryBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  late Razorpay _razorpay;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final idNumberController = TextEditingController();
  String idType = 'Aadhaar';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    nameController.text = user?.displayName ?? "";
    emailController.text = user?.email ?? "";

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
    addressController.dispose();
    idNumberController.dispose();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void startPayment() {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a booking date")),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_S6rSdArYDhTpvx',
      'amount': (widget.dormitory.price * 100).toInt(),
      'name': 'UrbanStay',
      'description': 'Booking for Dormitory ${widget.dormitory.dormitoryNumber}',
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
        userId: user!.uid,
        userName: nameController.text.trim(),
        email: emailController.text.trim(),
        contactNumber: contactController.text.trim(),
        idProofType: idType,
        idProofNumber: idNumberController.text.trim(),
        permanentAddress: addressController.text.trim(),
        itemId: widget.dormitory.id,
        itemType: 'dormitory',
        date: "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
        status: status,
      );

      await _bookingService.createBooking(booking);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful! Dormitory Booking Confirmed."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Book Dormitory Hall")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Booking: Dormitory ${widget.dormitory.dormitoryNumber}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: "Contact Number"),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: idType,
                decoration: const InputDecoration(labelText: "ID Proof Type"),
                items: ['Aadhaar', 'Voter ID', 'Driving License']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => idType = v!),
              ),
              TextFormField(
                  controller: idNumberController,
                  decoration: const InputDecoration(labelText: "ID Proof Number"),
                  validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Permanent Address"),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(selectedDate == null
                      ? "Select Booking Date"
                      : "Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: Text(
                    "Pay ₹${widget.dormitory.price} & Book Now",
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: startPayment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
