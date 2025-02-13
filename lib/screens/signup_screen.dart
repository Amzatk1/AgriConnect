import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key}); // ✅ Converted key to a super parameter

  @override
  SignupScreenState createState() => SignupScreenState(); // ✅ Removed underscore from class name
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _signup() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty!")), // ✅ Added validation message
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long!")), // ✅ Enforced password length
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await _authService.signUp(emailController.text, passwordController.text);

      if (!mounted) return; // ✅ Prevents navigation issues if widget is unmounted

      setState(() => _isLoading = false);

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard'); // ✅ Redirect to Dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed! Please try again.")), // ✅ Improved error message
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")), // ✅ Displays detailed error message
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")), // ✅ Used const
      body: Padding(
        padding: const EdgeInsets.all(16.0), // ✅ Used const
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"), // ✅ Used const
            ),
            const SizedBox(height: 10), // ✅ Used const for spacing
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"), // ✅ Used const
            ),
            const SizedBox(height: 20), // ✅ Used const
            _isLoading
                ? const CircularProgressIndicator() // ✅ Used const
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text("Sign Up"), // ✅ Used const
                  ),
          ],
        ),
      ),
    );
  }
}
