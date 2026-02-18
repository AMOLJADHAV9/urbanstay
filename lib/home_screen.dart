import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing_screen.dart';
import 'customer_rooms_screen.dart';
import 'customer_halls_screen.dart';
import 'customer_bookings_screen.dart';
import 'customer_cottages_screen.dart';
import 'customer_dormitory_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Widget dashboardCard(String title, IconData icon, Widget screen) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => screen,
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("UrbanStay Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LandingScreen(),
                ),
                (route) => false,
              );
            },
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
              user?.displayName ?? "User",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              user?.email ?? "",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Dashboard Options
            Expanded(
              child: ListView(
                children: [
                  dashboardCard(
                    "View Available Rooms",
                    Icons.hotel,
                    const CustomerRoomsScreen(),
                  ),

                  dashboardCard(
                    "View Function Halls",
                    Icons.meeting_room,
                    const CustomerHallsScreen(),
                  ),

                  dashboardCard(
                    "View Cottages",
                    Icons.home_work,
                    const CustomerCottagesScreen(),
                  ),

                  dashboardCard(
                    "View Dormitory Halls",
                    Icons.apartment,
                    const CustomerDormitoryScreen(),
                  ),

                  dashboardCard(
                    "My Bookings",
                    Icons.book_online,
                    const CustomerBookingsScreen(),
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
