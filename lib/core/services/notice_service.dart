import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeService {
  final CollectionReference announcementsRef =
      FirebaseFirestore.instance.collection('announcements');

  Future<void> addNotice(String text) async {
    await announcementsRef.add({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getNoticesStream() {
    return announcementsRef.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateNotice(String docId, String updatedText) async {
    await announcementsRef.doc(docId).update({'text': updatedText});
  }

  Future<void> deleteNotice(String docId) async {
    await announcementsRef.doc(docId).delete();
  }
}
