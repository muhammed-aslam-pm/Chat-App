import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  //instance of auth
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser() {
    return auth.currentUser;
  }

  //signin 
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      // save user info if it doesnt exist
      firestore
          .collection(
              "Users") //have to create a db name users and doc named email
          .doc(userCredential.user!.uid)
          .set({"uid": userCredential.user!.uid, "email": email,"name":'aslam'});

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }


//signup
    Future<UserCredential> signUpWithEmailPassword(String email, password,name) async {
    try {
      // create user
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // save user info in a seperate doc
      firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({"uid": userCredential.user!.uid, "email": email,"name":name});

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }  

  //sign out 
  Future<void> signOut() async {
    return await auth.signOut();
  }

  //errors
}