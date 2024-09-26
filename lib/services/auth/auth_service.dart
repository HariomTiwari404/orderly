import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      String? fcmToken = await _firebaseMessaging.getToken();

      await _database.child('users/${userCredential.user!.uid}').update({
        'uid': userCredential.user!.uid,
        'email': email,
        'fcmToken': fcmToken,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      String? fcmToken = await _firebaseMessaging.getToken();

      final DatabaseEvent event = await _database
          .child('users')
          .orderByChild('username')
          .equalTo(username)
          .once();

      if (event.snapshot.exists) {
        throw Exception('Username already exists');
      }

      await _database.child('users/${userCredential.user!.uid}').set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'fcmToken': fcmToken,
        'contacts': [], // Initialize contacts field as an empty array
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
