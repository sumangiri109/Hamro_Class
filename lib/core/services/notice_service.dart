import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoticeService {
  final CollectionReference announcementsRef = FirebaseFirestore.instance
      .collection('announcements');

  // Add new announcement post
  Future<void> addNotice(String text, String userEmail) async {
    await announcementsRef.add({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': false,
      'userEmail': userEmail,
    });
  }

  // Stream announcements ordered by timestamp descending (newest first)
  Stream<QuerySnapshot> getNoticesStream() {
    return announcementsRef.orderBy('timestamp', descending: true).snapshots();
  }

  // Update announcement text and mark as edited
  Future<void> updateNotice(String docId, String updatedText) async {
    await announcementsRef.doc(docId).update({
      'text': updatedText,
      'isEdited': true,
    });
  }

  // Delete announcement post
  Future<void> deleteNotice(String docId) async {
    await announcementsRef.doc(docId).delete();
  }

  // ===== Comment Features =====

  // Add comment under a specific announcement
  Future<void> addComment({
    required String noticeId,
    required String commentText,
    required String userEmail,
  }) async {
    await announcementsRef.doc(noticeId).collection('comments').add({
      'text': commentText,
      'timestamp': FieldValue.serverTimestamp(),
      'userEmail': userEmail,
      'isEdited': false,
    });
  }

  // Stream comments for a specific announcement, ordered oldest first
  Stream<QuerySnapshot> getCommentsStream(String noticeId) {
    return announcementsRef
        .doc(noticeId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Update comment text and mark as edited
  Future<void> updateComment(
    String noticeId,
    String commentId,
    String newText,
  ) async {
    await announcementsRef
        .doc(noticeId)
        .collection('comments')
        .doc(commentId)
        .update({'text': newText, 'isEdited': true});
  }

  // Delete comment
  Future<void> deleteComment(String noticeId, String commentId) async {
    await announcementsRef
        .doc(noticeId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}
