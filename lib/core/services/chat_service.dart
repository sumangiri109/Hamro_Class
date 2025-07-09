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

    // Fetch user by email and check if role is CR
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    final isCR = userQuery.docs.isNotEmpty
        ? (userQuery.docs.first.data()['role'] == 'CR')
        : false;

    await _chatCollection.add({
      'message': message,
      'email': user.email,
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': false,
      'isDeleted': false,
      'isCR': isCR,
      'reactions': {},
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

  Future<void> toggleReaction(
    String docId,
    String emoji,
    String userEmail,
    bool hasReacted,
  ) async {
    final docRef = _chatCollection.doc(docId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final reactions = Map<String, List<dynamic>>.from(data['reactions'] ?? {});

    if (hasReacted) {
      reactions[emoji]?.remove(userEmail);
      if (reactions[emoji]?.isEmpty ?? true) {
        reactions.remove(emoji);
      }
    } else {
      reactions.putIfAbsent(emoji, () => []);
      if (!reactions[emoji]!.contains(userEmail)) {
        reactions[emoji]!.add(userEmail);
      }
    }

    await docRef.update({'reactions': reactions});
  }
}
