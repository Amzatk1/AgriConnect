import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers for Editing
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController(); // 👤 Profile Picture

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      Map<String, dynamic>? userData = await _authService.getCurrentUser();
      if (!mounted) return;

      if (userData != null) {
        setState(() {
          _userData = userData;
          _firstNameController.text = userData['first_name'] ?? '';
          _surnameController.text = userData['surname'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _profilePicController.text = userData['profile_pic'] ?? ''; // 👤 Profile Picture
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("🔥 Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_firstNameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      _showSnackbar("⚠️ All fields are required!");
      return;
    }

    try {
      String? token = await _authService.getToken();
      if (token == null) return;

      bool success = await _authService.updateProfile(
        _firstNameController.text.trim(),
        _surnameController.text.trim(),
        _emailController.text.trim(),
        _profilePicController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        _showSnackbar("✅ Profile updated successfully!");
        setState(() => _isEditing = false);
        _fetchUserData(); // Refresh profile
      } else {
        _showSnackbar("❌ Failed to update profile. Try again.");
      }
    } catch (e) {
      debugPrint("🔥 Error updating profile: $e");
      _showSnackbar("❌ Something went wrong!");
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                      // 👤 Profile Picture
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _userData?['profile_pic'] != null &&
                                  _userData?['profile_pic']!.isNotEmpty
                              ? NetworkImage(_userData?['profile_pic']!)
                              : const AssetImage('assets/images/default_profile.png')
                                  as ImageProvider, // 👤 Default Image
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
                                  "👤 Name: ${_userData?['first_name'] ?? 'N/A'} ${_userData?['surname'] ?? ''}",
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
                          await _authService.logout();
                          if (!mounted) return;
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
    );
  }
}
