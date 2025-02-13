import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key}); // ✅ Converted key to a super parameter

  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel logout
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm logout
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (!context.mounted) return; // ✅ Prevents navigation issues if widget is unmounted
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // ✅ Clears navigation stack after logout
      } catch (e) {
        debugPrint("Error logging out: $e"); // ✅ Improved error handling
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logout failed. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"), // ✅ Used const
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // ✅ Used const
            onPressed: () => _logout(context), // ✅ Logout with confirmation dialog
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome to the Dashboard!"), // ✅ Used const
      ),
    );
  }
}
