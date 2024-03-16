// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// model gives what structure user will look like, easily communicate when there are multiple classes

class User {
  final String uid;
  final String username;
  final String email;

  User({required this.uid, required this.username, required this.email});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'username': username,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
    );
  }
}