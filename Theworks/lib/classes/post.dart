import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final String language;
  final Timestamp createdAt;
  final List<Map<String, dynamic>> comments;

  Post({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.language,
    required this.createdAt,
    required this.comments,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      postId: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      language: data['language'] ?? 'General',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'language': language,
      'createdAt': createdAt,
      'comments': comments,
    };
  }
}
