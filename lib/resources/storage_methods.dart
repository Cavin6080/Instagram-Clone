import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create a function to add the image to firebase storage
  Future<String> uploadImageToStorage(
      String childname, Uint8List file, bool isPost) async {
    Reference ref =
        _storage.ref().child(childname).child(_auth.currentUser!.uid);

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id); //name of the post is unique id
    }

    UploadTask uploadtask = ref.putData(file);

    TaskSnapshot snap = await uploadtask;
    String download_url = await snap.ref.getDownloadURL();

    return download_url;
  }
}
