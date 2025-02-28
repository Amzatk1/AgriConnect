import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8000/api';
  final storage = const FlutterSecureStorage();

  // ✅ **Login with Django API**
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          await saveToken(data['token']);
          debugPrint("✅ Login successful! Token saved.");
          return true;
        } else {
          debugPrint("❌ Login response missing token.");
          return false;
        }
      } else {
        debugPrint("❌ Login failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Login Error: $e");
      return false;
    }
  }

  // 🔹 **Signup with Django**
  Future<bool> signUp(String email, String password, String firstName, String surname) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'surname': surname,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint("✅ Signup successful!");
        return true;
      } else {
        debugPrint("❌ Signup failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Signup Error: $e");
      return false;
    }
  }

  // 🔹 **Logout User**
  Future<bool> logout() async {
    String? token = await getToken();
    if (token == null) {
      debugPrint("⚠️ No token found. User not logged in.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        await deleteToken(); // ✅ Remove token on logout
        debugPrint("✅ Logged out successfully.");
        return true;
      } else {
        debugPrint("❌ Logout failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Logout Error: $e");
      return false;
    }
  }

  // 🔹 **Reset Password**
  Future<bool> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Password reset email sent.");
        return true;
      } else {
        debugPrint("❌ Reset Password failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Reset Password Error: $e");
      return false;
    }
  }

  // ✅ **Fetch Current User Details**
  Future<Map<String, dynamic>?> getCurrentUser() async {
    String? token = await getToken();
    if (token == null) {
      debugPrint("⚠️ No token found. User not logged in.");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ User data fetched successfully.");
        return jsonDecode(response.body);
      } else {
        debugPrint("❌ Failed to fetch user data: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("🔥 Error fetching user data: $e");
      return null;
    }
  }

  // ✅ **Update Profile**
  Future<bool> updateProfile(String firstName, String surname, String email, String profilePic) async {
    String? token = await getToken();
    if (token == null) {
      debugPrint("⚠️ No token found. User not logged in.");
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'first_name': firstName,
          'surname': surname,
          'email': email,
          'profile_pic': profilePic,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Profile updated successfully.");
        return true;
      } else {
        debugPrint("❌ Profile update failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Profile Update Error: $e");
      return false;
    }
  }

  // ✅ **Delete Account**
  Future<bool> deleteAccount() async {
    String? token = await getToken();
    if (token == null) {
      debugPrint("⚠️ No token found. User not logged in.");
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-account/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        await deleteToken(); // ✅ Remove token on account deletion
        debugPrint("✅ Account deleted successfully.");
        return true;
      } else {
        debugPrint("❌ Account deletion failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Error deleting account: $e");
      return false;
    }
  }

  // 🔹 **Save Token Securely**
  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  // 🔹 **Retrieve Token**
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  // 🔹 **Delete Token (on logout)**
  Future<void> deleteToken() async {
    await storage.delete(key: 'auth_token');
  }
}
