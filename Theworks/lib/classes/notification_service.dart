import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final CollectionReference _notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  Future<void> sendNotification({
    required String toUserId,
    required String fromUserName,
    required String message,
    required String relatedPostId,
  }) async {
    await _notificationsCollection.add({
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'message': message,
      'relatedPostId': relatedPostId,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _notificationsCollection
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'read': true});
  }
}
