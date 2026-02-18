import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Create user in Firebase Auth
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update display name
      await credential.user!
          .updateDisplayName(fullNameController.text.trim());

      // Save customer data to Firestore
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Go to Home
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  onPressed: registerUser,
                  child: const Text("Create Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
