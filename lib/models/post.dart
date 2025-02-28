class Post {
  final String id;
  final String title;
  final String description;
  final String userId;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.timestamp,
  });

  // ✅ Convert JSON to Post Model
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),  // Convert ID to String if needed
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // ✅ Convert Post Model to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
