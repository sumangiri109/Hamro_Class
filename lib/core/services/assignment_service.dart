import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _posts(String subject) {
    return _firestore.collection('assignments_$subject');
  }

  Stream<QuerySnapshot> streamPosts(String subject) {
    return _posts(subject).orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> addPost(
    String subject,
    String text, {
    String? fileUrl,
    String? fileName,
  }) async {
    final postData = {
      'text': text,
      'timestamp': Timestamp.now(),
      'isEdited': false,
    };

    // Add file info only if present
    if (fileUrl != null && fileName != null) {
      postData['fileUrl'] = fileUrl;
      postData['fileName'] = fileName;
    }

    await _posts(subject).add(postData);
  }

  Future<void> updatePost(String subject, String postId, String newText) async {
    await _posts(subject).doc(postId).update({
      'text': newText,
      'isEdited': true,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deletePost(String subject, String postId) async {
    await _posts(subject).doc(postId).delete();
  }
}
