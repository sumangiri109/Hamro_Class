import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user with email & password, create Firestore doc, and send verification email
  Future<String> signUpUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore immediately on signup
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'role': 'student',
        'isAccepted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send verification email once here
      await cred.user!.sendEmailVerification();

      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Log in user, check email verification & create Firestore doc if needed
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!cred.user!.emailVerified) {
          try {
            await cred.user!.delete();
          } catch (e) {
            // Handle deletion errors gracefully (log, etc.)
          }
          await _auth.signOut(); // sign out immediately

          return "email_not_verified";
        }

        // Check Firestore if user doc exists (redundant now, but safe)
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create user document with isAccepted = false (waiting approval)
          await _firestore.collection('users').doc(cred.user!.uid).set({
            'uid': cred.user!.uid,
            'email': email,
            'role': 'student',
            'isAccepted': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
          res = "not_accepted"; // user must wait approval
        } else {
          bool isAccepted = userDoc['isAccepted'] ?? false;
          if (isAccepted) {
            res = "success";
          } else {
            res = "not_accepted";
          }
        }
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        res = "Incorrect password.";
      } else {
        res = e.message ?? e.toString();
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc['role'];
      }
    }
    return null;
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}
