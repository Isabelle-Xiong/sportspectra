import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportspectra/models/livestream.dart';
import 'package:sportspectra/providers/user_provider.dart';
import 'package:sportspectra/resources/storage_methods.dart';
import 'package:sportspectra/utils/utils.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();

  Future<String> startLiveStream(
      BuildContext context, String title, Uint8List? image) async {
    final user = Provider.of<UserProvider>(context, listen: false);

    String channelId = '';
    try {
      if (title.isNotEmpty && image != null) {
        // make sure one user cannot have 2 streams. If user document exists in livestream collection, show error message
        if (!((await _firestore
                .collection('livestream')
                .doc('${user.user.uid}${user.user.username}')
                .get())
            .exists)) {
          String thumbnailURL = await _storageMethods.upLoadImageToStorage(
              'Livestream-thumbnails', image, user.user.uid);

          String channelId = '${user.user.uid}${user.user.username}';
          LiveStream liveStream = LiveStream(
              title: title,
              image: thumbnailURL,
              uid: user.user.uid,
              username: user.user.username,
              viewers: 0,
              channelId: channelId,
              startedAt: DateTime.now());
// map is saved to Firestore under the collection 'livestream' with the document ID being channelId
          _firestore
              .collection('livestream')
              .doc(channelId)
              .set(liveStream.toMap());
        } else {
          showSnackBar(context, 'Another livestream occurring already');
        }
      } else {
        showSnackBar(context, 'PLease enter all the fields');
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return channelId;
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try {
      await _firestore.collection('livestream').doc(id).update({
        // if isIncrease is true, we are coming from feed screen, so increment by 1. If false, then we are leaving the broadcast screen, so decrease by 1
        'viewers': FieldValue.increment(isIncrease ? 1 : -1),
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> endLiveStream(String channelId) async {
    try {
      // get all comments in subcollection and delete it
      QuerySnapshot snap = await _firestore
          .collection('livestream')
          .doc(channelId)
          .collection('comments')
          .get();

      for (int i = 0; i < snap.docs.length; i++) {
        await _firestore
            .collection('livestream')
            .doc(channelId)
            .collection('comments')
            .doc(
              ((snap.docs[i].data()! as dynamic)['commentId']),
            )
            .delete();
      }
      // delete the whole collection after deleting subcollection
      await _firestore.collection('livestream').doc(channelId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Other methods can be added here
}
