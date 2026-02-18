import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_home_screen.dart';

class StaffRegisterScreen extends StatefulWidget {
  const StaffRegisterScreen({super.key});

  @override
  State<StaffRegisterScreen> createState() => _StaffRegisterScreenState();
}

class _StaffRegisterScreenState extends State<StaffRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  Future<void> registerStaff() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await credential.user!
          .updateDisplayName(fullNameController.text.trim());

      // Save staff data to Firestore
      await FirebaseFirestore.instance
          .collection('staff')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'position': positionController.text.trim(),
        'role': 'staff',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StaffHomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Registration")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter name" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter email" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: positionController,
                  decoration:
                      const InputDecoration(labelText: "Position / Role"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter position" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (value) =>
                      value!.length < 6 ? "Minimum 6 characters" : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: registerStaff,
                    child: const Text("Register as Staff"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
