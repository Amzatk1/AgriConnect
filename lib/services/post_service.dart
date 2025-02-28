import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../services/auth_service.dart';

class PostService {
  final String baseUrl = 'http://localhost:8000/api';
  final AuthService _authService = AuthService();

  // ✅ Create Post
  Future<bool> createPost(String title, String description) async {
    String? token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ✅ Fetch Posts
  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ✅ Delete Post
  Future<bool> deletePost(String postId) async {
    String? token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
