import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers for Editing
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController(); // 👤 Profile Picture URL Controller

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      _user = _auth.currentUser;
      if (_user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
        if (userDoc.exists) {
          if (!mounted) return; // ✅ Fix: Prevents UI update after async operation
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>?;
            _firstNameController.text = _userData?['firstName'] ?? '';
            _surnameController.text = _userData?['surname'] ?? '';
            _emailController.text = _userData?['email'] ?? '';
            _profilePicController.text = _userData?['profilePic'] ?? ''; // 👤 Load Profile Pic
            _isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() => _isLoading = false);
          debugPrint("⚠️ User document not found in Firestore.");
        }
      }
    } catch (e) {
      debugPrint("🔥 Error fetching user data: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_firstNameController.text.isEmpty || _surnameController.text.isEmpty || _emailController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ All fields are required!")),
      );
      return;
    }

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'firstName': _firstNameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'profilePic': _profilePicController.text.trim(), // 👤 Save Profile Pic
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated successfully!")),
      );

      setState(() {
        _isEditing = false;
      });

      _getUserData(); // Refresh profile
    } catch (e) {
      debugPrint("🔥 Error updating profile: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to update profile. Try again!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text("⚠️ No profile data found."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👤 Profile Picture Section
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _userData?['profilePic'] != null && _userData?['profilePic']!.isNotEmpty
                              ? NetworkImage(_userData?['profilePic']!)
                              : const AssetImage('assets/images/default_profile.png') as ImageProvider, // 👤 Default Image
                        ),
                      ),
                      const SizedBox(height: 10),

                      _isEditing
                          ? Column(
                              children: [
                                TextField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(labelText: "📝 First Name"),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _surnameController,
                                  decoration: const InputDecoration(labelText: "📝 Surname"),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(labelText: "📧 Email"),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _profilePicController,
                                  decoration: const InputDecoration(labelText: "🌄 Profile Picture URL"),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _updateProfile,
                                  child: const Text("Save Changes"),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "👤 Name: ${_userData?['firstName'] ?? 'N/A'} ${_userData?['surname'] ?? ''}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  "📧 Email: ${_userData?['email'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        child: Text(_isEditing ? "Cancel" : "Edit Profile"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          await _authService.logout(context);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
    );
  }
}
