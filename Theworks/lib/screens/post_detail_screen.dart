import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theworks/classes/post.dart';
import 'package:theworks/classes/post_service.dart';
import 'package:theworks/classes/notification_service.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final PostService _postService = PostService();
  final NotificationService _notificationService = NotificationService();
  final auth = FirebaseAuth.instance;

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final user = auth.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        
        String authorName = 'Anonymous';
        if (userData != null) {
          if (userData.containsKey('companyName') && userData['companyName'].toString().isNotEmpty) {
            authorName = userData['companyName'];
          } else if (userData.containsKey('displayName') && userData['displayName'].toString().isNotEmpty) {
            authorName = userData['displayName'];
          }
        }
        
        if (authorName == 'Anonymous' && user.displayName != null && user.displayName!.isNotEmpty) {
            authorName = user.displayName!;
        }

        final comment = {
          'authorId': user.uid,
          'authorName': authorName,
          'text': _commentController.text,
          'createdAt': Timestamp.now(),
        };

        await _postService.addComment(widget.post.postId, comment);

        if (user.uid != widget.post.authorId) {
          await _notificationService.sendNotification(
            toUserId: widget.post.authorId,
            fromUserName: authorName,
            message: 'commented on your post: ${widget.post.title}',
            relatedPostId: widget.post.postId,
          );
        }

        _commentController.clear();
        // The stream will rebuild the UI, so no need for setState
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'By ${widget.post.authorName}',
                        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                      const Spacer(),
                      Chip(label: Text(widget.post.language)),
                    ],
                  ),
                  const SizedBox(height: 8),
                   Text(
                    DateFormat('MMM d, yyyy HH:mm').format(widget.post.createdAt.toDate()),
                     style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    widget.post.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('posts').doc(widget.post.postId).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final postData = snapshot.data!.data() as Map<String, dynamic>;
                      final comments = (postData['comments'] as List<dynamic>).cast<Map<String, dynamic>>();

                      if (comments.isEmpty) {
                        return const Text('No comments yet.');
                      }

                      // Sort comments by createdAt descending
                      comments.sort((a, b) => (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp));


                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final createdAt = (comment['createdAt'] as Timestamp).toDate();

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['text'],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                       Text(
                                        'By ${comment['authorName']}',
                                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                                      ),
                                      Text(
                                        DateFormat('MMM d, HH:mm').format(createdAt),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
