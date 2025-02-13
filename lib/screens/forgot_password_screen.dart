import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key}); // ✅ Converted key to a super parameter

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState(); // ✅ Removed underscore
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _resetPassword() async {
    setState(() => _isLoading = true);
    
    try {
      bool success = await _authService.resetPassword(emailController.text);
      
      if (!mounted) return; // ✅ Prevents navigation issues

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent!")), // ✅ Used const
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error sending reset email!")), // ✅ Used const
        );
      }
    } catch (e) {
      debugPrint("Error in resetPassword: $e"); // ✅ Debugging for error handling
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")), // ✅ Used const
      body: Padding(
        padding: const EdgeInsets.all(16.0), // ✅ Used const
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Enter your email"), // ✅ Used const
            ),
            const SizedBox(height: 20), // ✅ Used const
            _isLoading
                ? const CircularProgressIndicator() // ✅ Used const
                : ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text("Reset Password"), // ✅ Used const
                  ),
          ],
        ),
      ),
    );
  }
}
