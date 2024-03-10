import 'package:flutter/material.dart';
import 'package:sportspectra/models/user.dart';

// storing user model here with default initial values. When you call set user anywhere, it will set global user to the user parameter and notify all listeners (all classes that have user provider stored in there)
class UserProvider extends ChangeNotifier {
  User _user = User(
    email: '',
    username: '',
    uid: '',
  );
  // because user is private variable, we want to access it
  User get user => _user;

// setUser receives user model and will set global user to this parameter user
  setUser(User user) {
    _user = user;
    // we want to let other classes that are using user provider that the global _user has changed.
    notifyListeners();
  }
}
