import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  // This defines a private instance variable _userRef, which is a reference to the Firestore collection named 'users'.
  final _userRef = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;

  signUpUser() async {}
}
