import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _posts(String subject) {
    return _firestore.collection('assignments_$subject');
  }

  // Stream assignment posts (newest first)
  Stream<QuerySnapshot> streamPosts(String subject) {
    return _posts(subject).orderBy('timestamp', descending: true).snapshots();
  }

  // Add a new post; fetches current user email internally
  Future<void> addPost(
    String subject,
    String text, {
    String? fileUrl,
    String? fileName,
  }) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'unknown';
    final data = {
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': false,
      'userEmail': userEmail,
      if (fileUrl != null && fileName != null) 'fileUrl': fileUrl,
      if (fileUrl != null && fileName != null) 'fileName': fileName,
    };

    await _posts(subject).add(data);
  }

  // Update an existing post
  Future<void> updatePost(String subject, String postId, String newText) async {
    await _posts(subject).doc(postId).update({
      'text': newText,
      'isEdited': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Delete a post
  Future<void> deletePost(String subject, String postId) async {
    await _posts(subject).doc(postId).delete();
  }

  // ===== Comment Features =====

  // Add a comment to a post; fetches current user email internally
  Future<void> addComment({
    required String subject,
    required String postId,
    required String commentText,
  }) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'unknown';
    final commentsRef = _posts(subject).doc(postId).collection('comments');
    await commentsRef.add({
      'text': commentText,
      'timestamp': FieldValue.serverTimestamp(),
      'userEmail': userEmail,
      'isEdited': false,
    });
  }

  // Stream comments for a post (oldest first)
  Stream<QuerySnapshot> getCommentsStream(String subject, String postId) {
    return _posts(subject)
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Update a comment
  Future<void> updateComment({
    required String subject,
    required String postId,
    required String commentId,
    required String newText,
  }) async {
    final commentDoc = _posts(
      subject,
    ).doc(postId).collection('comments').doc(commentId);
    await commentDoc.update({
      'text': newText,
      'isEdited': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Delete a comment
  Future<void> deleteComment({
    required String subject,
    required String postId,
    required String commentId,
  }) async {
    final commentDoc = _posts(
      subject,
    ).doc(postId).collection('comments').doc(commentId);
    await commentDoc.delete();
  }
}
