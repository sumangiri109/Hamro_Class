import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PollService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getPollsStream() {
    return _firestore
        .collection('polls')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addPoll(String question, List<String> options) async {
    await _firestore.collection('polls').add({
      'question': question,
      'options': options,
      'votes': {}, // userId -> optionIndex
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePoll(String pollId, String newQuestion) async {
    await _firestore.collection('polls').doc(pollId).update({
      'question': newQuestion,
    });
  }

  Future<void> updateOptions(String pollId, List<String> options) async {
    await _firestore.collection('polls').doc(pollId).update({
      'options': options,
    });
  }

  Future<void> deletePoll(String pollId) async {
    await _firestore.collection('polls').doc(pollId).delete();
  }

  Future<void> vote(String pollId, int selectedIndex) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final pollRef = _firestore.collection('polls').doc(pollId);
    await pollRef.update({'votes.${user.uid}': selectedIndex});
  }

  Future<void> removeVote(String pollId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final pollRef = _firestore.collection('polls').doc(pollId);
    await pollRef.update({'votes.${user.uid}': FieldValue.delete()});
  }
}
