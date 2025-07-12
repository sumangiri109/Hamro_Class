import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _posts(String subject) {
    return _firestore.collection('assignments_$subject');
  }

  Stream<QuerySnapshot> streamPosts(String subject) {
    return _posts(subject).orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> addPost(String subject, String text) async {
    await _posts(
      subject,
    ).add({'text': text, 'timestamp': Timestamp.now(), 'isEdited': false});
  }

  Future<void> updatePost(String subject, String postId, String newText) async {
    await _posts(subject).doc(postId).update({
      'text': newText,
      'isEdited': true,
      'timestamp': Timestamp.now(), // update timestamp on edit if you want
    });
  }

  Future<void> deletePost(String subject, String postId) async {
    await _posts(subject).doc(postId).delete();
  }
}
