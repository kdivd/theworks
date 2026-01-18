import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theworks/classes/post.dart';

class PostService {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  Stream<List<Post>> getPosts() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  Future<void> createPost(Post post) {
    return _postsCollection.add(post.toMap());
  }

  Future<void> addComment(String postId, Map<String, dynamic> comment) {
    return _postsCollection.doc(postId).update({
      'comments': FieldValue.arrayUnion([comment])
    });
  }

  Future<Post?> getPost(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (doc.exists) {
      return Post.fromFirestore(doc);
    }
    return null;
  }

  Future<void> deletePost(String postId) {
    return _postsCollection.doc(postId).delete();
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) {
    return _postsCollection.doc(postId).update(data);
  }
}
