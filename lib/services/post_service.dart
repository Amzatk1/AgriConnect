import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(String title, String description) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    await _firestore.collection('posts').add({
      'userId': userId,
      'title': title,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Post>> getPosts() {
    return _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Post.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }
}
