import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_login_screen.dart';
import 'manage_rooms_screen.dart';
import 'manage_function_hall_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_cottages_screen.dart';
import 'manage_dormitory_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  String fullName = "";
  String position = "";

  @override
  void initState() {
    super.initState();
    loadStaffData();
  }

  Future<void> loadStaffData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          fullName = doc['fullName'] ?? "";
          position = doc['position'] ?? "";
        });
      }
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const StaffLoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget dashboardCard(
      String title, IconData icon, Widget? screen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => screen,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title coming soon")),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Section
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 45, color: Colors.white),
            ),
            const SizedBox(height: 15),

            Text(
              fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              position,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // Dashboard Options
            Expanded(
              child: ListView(
                children: [
                  dashboardCard(
                    "View Bookings",
                    Icons.calendar_today,
                    const ManageBookingsScreen(),
                  ),

                  dashboardCard(
                    "Manage Rooms",
                    Icons.hotel,
                    const ManageRoomsScreen(),
                  ),

                  dashboardCard(
                    "Manage Function Hall",
                    Icons.meeting_room,
                    const ManageFunctionHallScreen(),
                  ),

                  dashboardCard(
                    "Manage Cottages",
                    Icons.home_work,
                    const ManageCottagesScreen(),
                  ),

                  dashboardCard(
                    "Manage Dormitory Hall",
                    Icons.apartment,
                    const ManageDormitoryScreen(),
                  ),

                  dashboardCard(
                    "Manage Restaurant",
                    Icons.restaurant,
                    null,
                  ),

                  dashboardCard(
                    "View Customers",
                    Icons.people,
                    null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
