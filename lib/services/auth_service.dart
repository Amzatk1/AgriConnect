import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Get the currently logged-in user
  User? get currentUser => _auth.currentUser;

  // 🔹 Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint("✅ Password reset email sent to: $email");
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("🔥 Error sending password reset email: ${e.message}");
      return false;
    }
  }

  // 🔹 Signup with Email & Password + Save Name to Firestore
  Future<User?> signUp(String email, String password, String firstName, String surname) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // ✅ Send Email Verification
        await user.sendEmailVerification();
        debugPrint("📧 Verification email sent to: ${user.email ?? 'Unknown email'}");

        // ✅ Save user info to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'surname': surname,
          'email': user.email ?? 'No email',
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("🔥 Signup Error: ${e.message}");
      return null;
    }
  }

  // 🔹 Login with Email & Password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          debugPrint("⚠️ Email not verified: ${user.email ?? 'Unknown email'}");
          return null;
        }

        debugPrint("✅ Login successful: ${user.email ?? 'Unknown email'}");
        return user;
      } else {
        debugPrint("🔥 Login failed: No user returned");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("🔥 Login Error: ${e.message}");
      return null;
    }
  }

  // 🔹 Logout User
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      debugPrint("✅ User logged out successfully");
    } catch (e) {
      debugPrint("🔥 Error logging out: $e");
    }
  }
}
