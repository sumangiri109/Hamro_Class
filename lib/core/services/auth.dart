import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user with email & password and send verification email (no Firestore doc yet)
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

      // Send verification email
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
          // Delete the unverified user from Firebase Auth
          await cred.user!.delete();
          await _auth.signOut(); // sign out immediately

          return "email_not_verified";
        }

        // Check Firestore if user doc exists
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
      // Handle specific Firebase errors
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

  // Get current user role (for logic or debug)
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

  // Logout
  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}
