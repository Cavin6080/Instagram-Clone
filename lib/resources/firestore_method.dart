import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post function
  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profileimage) async {
    String result = 'Some error occured';
    try {
      String photoURL =
          await StorageMethods().uploadImageToStorage("posts", file, true);
      String postID = const Uuid().v1();
      //to create a post
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postID: postID,
        datePublished: DateTime.now(),
        postURL: photoURL,
        profileImage: profileimage,
        likes: [],
      );

      _firestore.collection('posts').doc(postID).set(post.toJson());
      result = 'success';
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  Future<void> likePost(String postID, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postID).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postID).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postID, String text, String uid, String name,
      String profileImage) async {
    try {
      if (text.isNotEmpty) {
        String comment_id = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postID)
            .collection('comments')
            .doc(comment_id)
            .set({
          'profileImage': profileImage,
          'name': name,
          'uid': uid,
          'text': text,
          'comment_id': comment_id,
          'datePublished': DateTime.now(),
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //deleting the post
  Future<void> deletePost(String postID) async {
    try {
      await _firestore.collection('posts').doc(postID).delete();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> followUser(String uid, String followid) async {
    try {
      DocumentSnapshot snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      List following = (snap.data() as dynamic)['following'];
      if (following.contains(followid)) {
        await _firestore.collection('users').doc(followid).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(followid).update({
          'following': FieldValue.arrayRemove([followid])
        });
      } else {
        await _firestore.collection('users').doc(followid).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(followid).update({
          'following': FieldValue.arrayUnion([followid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
