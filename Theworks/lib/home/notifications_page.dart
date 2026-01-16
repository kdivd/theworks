import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:theworks/classes/notification_service.dart';
import 'package:theworks/classes/post_service.dart';
import 'package:theworks/routes.dart';
import 'package:intl/intl.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final NotificationService _notificationService = NotificationService();
  final PostService _postService = PostService();
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: Text('Please log in to see notifications.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationService.getUserNotifications(_user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No notifications yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notificationDoc = notifications[index];
              final data = notificationDoc.data() as Map<String, dynamic>;
              final bool isRead = data['read'] ?? false;
              final Timestamp? createdAt = data['createdAt'];

              return Card(
                color: isRead ? Colors.white : Colors.blue.shade50,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text((data['fromUserName'] ?? '?')[0].toUpperCase()),
                  ),
                  title: Text(
                    data['fromUserName'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['message'] ?? ''),
                      if (createdAt != null)
                        Text(
                          DateFormat('MMM d, HH:mm').format(createdAt.toDate()),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                    ],
                  ),
                  trailing: isRead
                      ? null
                      : const Icon(Icons.circle, color: Colors.blue, size: 12),
                  onTap: () async {
                    if (!isRead) {
                      await _notificationService.markAsRead(notificationDoc.id);
                    }
                    
                    final String? relatedPostId = data['relatedPostId'];
                    if (relatedPostId != null) {
                        // Fetch post and navigate
                        // Show loading indicator or simple navigation
                        final post = await _postService.getPost(relatedPostId);
                        if (post != null && context.mounted) {
                            Navigator.pushNamed(
                                context,
                                AppRoutes.postDetail,
                                arguments: post,
                            );
                        } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Post not found (maybe deleted).')),
                            );
                        }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}