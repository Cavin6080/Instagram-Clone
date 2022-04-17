import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance; //regestering the user
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //getting the user details for refreshing user
  Future<model.User> getUserDetails() async {
    User currentuser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentuser.uid).get();
    return model.User.fromSnap(snap);
  }

  //sign up the user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String result = 'Some error occured';
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        //Registering the user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        //photo url
        String photoURL = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        //creating user model
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoURL: photoURL,
        );

        //Adding the user in the database
        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        result = 'Success';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        result = 'The amail is badly formatted';
      } else if (e.code == 'weak-password') {
        result = 'Password is too weak';
      }
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  //function for logging in the user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String result = 'Some error occured';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        result = 'success';
      } else {
        result = 'Please enter all the fields';
      }
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  Future<void> signout() async {
    await _auth.signOut();
  }
}
