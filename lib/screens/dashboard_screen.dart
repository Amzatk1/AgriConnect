import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../models/post.dart';  // ✅ Ensure Post model is imported
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'create_post_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const DashboardScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  String _firstName = "User";
  String _lastLogin = "Loading...";
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ✅ Fetch User Data from Django API
  Future<void> _fetchUserData() async {
    var user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userId = user['id'].toString();
        _firstName = user['first_name'] ?? "User";
        _lastLogin = user['last_login'] ?? "Unknown";
      });
    }
  }

  // ✅ Logout User via Django API (with mounted check)
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
      bool success = await _authService.logout();
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        if (mounted) _showSnackbar("❌ Logout failed. Please try again.");
      }
    }
  }

  // ✅ Delete Post via Django API (with mounted check)
  Future<void> _deletePost(String postId) async {
    bool success = await _postService.deletePost(postId);
    if (success) {
      if (mounted) {
        _showSnackbar("✅ Post deleted successfully.");
        setState(() {}); // Refresh UI
      }
    } else {
      if (mounted) _showSnackbar("❌ Failed to delete post. Try again!");
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              child: FutureBuilder<List<Post>>(
                future: _postService.getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No posts yet. Be the first to post!"));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data![index];
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(post.title),
                          subtitle: Text(post.description),
                          trailing: _userId == post.userId
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
