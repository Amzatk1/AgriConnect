import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint("Login successful: ${userCredential.user?.email}"); // ✅ Replaced print() with debugPrint()
      return userCredential.user;
    } catch (e) {
      debugPrint("Error logging in: $e"); // ✅ Replaced print() with debugPrint()
      return null;
    }
  }

  // 🔹 Signup
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      debugPrint("Signup successful: ${userCredential.user?.email}");
      return userCredential.user;
    } catch (e) {
      debugPrint("Error signing up: $e");
      return null;
    }
  }

  // 🔹 Password Reset
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent to: $email");
      return true;
    } catch (e) {
      debugPrint("Error sending password reset email: $e");
      return false;
    }
  }

  // 🔹 Logout
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      if (!context.mounted) return; // ✅ Prevents navigation issues if widget is unmounted
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // ✅ Clears navigation stack after logout
      debugPrint("User logged out successfully"); // ✅ Added debug message
    } catch (e) {
      debugPrint("Error logging out: $e");
    }
  }
}
