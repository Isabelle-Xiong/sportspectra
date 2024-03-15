// for storing thumbnail into firebase
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> upLoadImageToStorage(
      String childName, Uint8List file, String uid) async {
    // reference created, first name of folder is childName, thumbnail name = uid
    Reference ref = _storage.ref().child(childName).child(uid);
    // put data into firebase
    UploadTask uploadTask = ref.putData(
      file,
      SettableMetadata(
        contentType: 'image/jpg',
      ),
    );
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }
}
