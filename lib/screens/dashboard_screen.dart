import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'create_post_screen.dart'; // ✅ Added Create Post Screen

class DashboardScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const DashboardScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _firstName = "User";
  String _lastLogin = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          _firstName = userDoc['firstName'] ?? "User";
          _lastLogin = _user!.metadata.lastSignInTime?.toString() ?? "Unknown";
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await _auth.signOut();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        debugPrint("🔥 Logout Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Logout failed. Please try again.")),
          );
        }
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      debugPrint("🔥 Error deleting post: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to delete post. Try again!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => widget.toggleTheme(!widget.isDarkMode),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "👋 Welcome, $_firstName!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "📅 Last Login: $_lastLogin",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 📌 Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(Icons.person, "Profile", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                }),
                _buildActionCard(Icons.settings, "Settings", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                }),
                _buildActionCard(Icons.logout, "Logout", () => _logout(context)),
              ],
            ),

            const SizedBox(height: 20),

            // 📌 Create Post Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
              },
              icon: const Icon(Icons.add),
              label: const Text("Create a Post"),
            ),

            const SizedBox(height: 20),

            // 📌 Recent Posts Section
            const Text(
              "📢 Recent Posts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No posts yet. Be the first to post!"));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(post['title']),
                          subtitle: Text(post['description']),
                          trailing: _user?.uid == post['userId']
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletePost(post.id),
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 Helper Function for Quick Actions
  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green[100],
            child: Icon(icon, color: Colors.green[800], size: 30),
          ),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}
