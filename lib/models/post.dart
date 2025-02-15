import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Import Firestore

class Post {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  // ✅ Convert Firestore Document to Post Object
  factory Post.fromMap(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] is Timestamp) ? (data['timestamp'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  // ✅ Convert Post Object to Firestore Document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp), // ✅ Converts DateTime to Firestore Timestamp
    };
  }
}
