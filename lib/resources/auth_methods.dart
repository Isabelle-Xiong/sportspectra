import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// whatever classes are inside user.dart, we can access with prefix of model
import 'package:sportspectra/models/user.dart' as model;
import 'package:sportspectra/providers/user_provider.dart';
import 'package:sportspectra/utils/utils.dart';

class AuthMethods {
  // This defines a private instance variable _userRef, which is a reference to the Firestore collection named 'users'.
  final _userRef = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;

  Future<bool> signUpUser(
    // BuildContext locates the nearest ancestor widget of a specific type
    BuildContext context,
    String email,
    String username,
    String password,
  ) async {
    // result initially sets to false, if result is false at end, make sure go below ad catch error
    bool res = false;
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // this cred.user comes from firebase, not from our self made model
      if (cred.user != null) {
        model.User user = model.User(
          username: username.trim(),
          email: email.trim(),
          // can only access uid when user is not null, hence the !
          uid: cred.user!.uid,
        );
        // all data will get converted to map
        await _userRef.doc(cred.user!.uid).set(user.toMap());
        // updating the user data stored in the UserProvider instance without causing any dependent widgets to rebuild immediately, since listen is set to false. It's a way to update the state managed by the provider without triggering UI updates at that moment.
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        // sign up function is successful, res = true
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      // ! makes sure it's not null
      showSnackBar(context, e.message!);
    }
    return res;
  }
}
