import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class LiveStream {
  final String title;
  final String image;
  final String uid;
  final String username;
  final startedAt;
  final int viewers;
  final String channelId;

  LiveStream({
    required this.title,
    required this.image,
    required this.uid,
    required this.username,
    required this.viewers,
    required this.channelId,
    required this.startedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'image': image,
      'uid': uid,
      'username': username,
      'viewers': viewers,
      'channelID': channelId,
      'startedAt': startedAt,
    };
  }

  factory LiveStream.fromMap(Map<String, dynamic> map) {
    return LiveStream(
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      viewers: map['viewers']?.toInt() ?? 0,
      channelId: map['channelID'] ?? '',
      startedAt: map['startedAt'] ?? '',
    );
  }
}
