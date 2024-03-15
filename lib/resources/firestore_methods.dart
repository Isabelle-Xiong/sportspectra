import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportspectra/providers/user_provider.dart';
import 'package:sportspectra/resources/storage_methods.dart';
import 'package:sportspectra/utils/utils.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();

  startLiveStream(BuildContext context, String title, Uint8List? image) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    try {
      if (title.isNotEmpty && image != null) {
        String thumbnailURL = await _storageMethods.upLoadImageToStorage(
            'Livestream-thumbnails', image, user.user.uid);
      } else {
        showSnackBar(context, 'PLease enter all the fields');
      }
    } catch (e) {}
  }

  // Other methods can be added here
}
