import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // ✅ Removed unused Firestore import

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _passwordVisible = false; // 👁️ Password Visibility Toggle

  void _signup() async {
    String firstName = firstNameController.text.trim();
    String surname = surnameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (firstName.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ All fields are required!")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Password must be at least 6 characters!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await _authService.signUp(email, password, firstName, surname);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Signup failed! Please try again.")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🔥 Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: "📝 First Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: surnameController,
              decoration: const InputDecoration(labelText: "📝 Surname"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "📧 Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: "🔒 Password",
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text("Sign Up"),
                  ),
          ],
        ),
      ),
    );
  }
}
