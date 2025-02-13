import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // ✅ Converted key to a super parameter

  @override
  LoginScreenState createState() => LoginScreenState(); // ✅ Removed underscore from class name
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty!")), // ✅ Added validation message
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await _authService.login(emailController.text, passwordController.text);

      if (!mounted) return; // ✅ Prevents navigation issues if widget is unmounted

      setState(() => _isLoading = false);

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard'); // ✅ Redirect to Dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password. Please try again.")), // ✅ Improved error message
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")), // ✅ Shows detailed error message
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")), // ✅ Used const
      body: Padding(
        padding: const EdgeInsets.all(16.0), // ✅ Used const
        child: Column(
          children: [
            SizedBox(
              height: 50, // ✅ Ensures uniform input field height
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"), // ✅ Used const
              ),
            ),
            const SizedBox(height: 10), // ✅ Used const for spacing
            SizedBox(
              height: 50, // ✅ Ensures uniform input field height
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"), // ✅ Used const
              ),
            ),
            const SizedBox(height: 20), // ✅ Used const
            _isLoading
                ? const CircularProgressIndicator() // ✅ Used const
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"), // ✅ Used const
                  ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text("Forgot Password?"), // ✅ Used const
            ),
          ],
        ),
      ),
    );
  }
}
