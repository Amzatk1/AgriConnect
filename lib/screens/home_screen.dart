import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // ✅ Converted key to a super parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to AgriConnect")), // ✅ Used const
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text( // ✅ Used const for Text widget
              "Welcome to AgriConnect!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), // ✅ Used const for SizedBox
            SizedBox(
              width: 200, // ✅ Ensures consistent button size
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Login"), // ✅ Used const for Text
              ),
            ),
            const SizedBox(height: 10), // ✅ Used const for SizedBox
            SizedBox(
              width: 200, // ✅ Ensures consistent button size
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Sign Up"), // ✅ Used const for Text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
