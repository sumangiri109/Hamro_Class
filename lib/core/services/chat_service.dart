import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _chatCollection = FirebaseFirestore.instance.collection('general_chat');

  Stream<QuerySnapshot> getMessagesStream() {
    return _chatCollection.orderBy('timestamp', descending: false).snapshots();
  }

  Future<void> sendMessage(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _chatCollection.add({
      'message': message,
      'email': user.email,
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': false,
      'isDeleted': false,
    });
  }

  Future<void> editMessage(String docId, String newMessage) async {
    await _chatCollection.doc(docId).update({
      'message': newMessage,
      'isEdited': true,
    });
  }

  Future<void> deleteMessage(String docId, String email) async {
    await _chatCollection.doc(docId).update({
      'message': "$email deleted this message",
      'isDeleted': true,
    });
  }
}
