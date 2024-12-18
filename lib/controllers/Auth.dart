import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:hedieaty/main.dart';

import '../models/AppUser.dart';


class MyAuth{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  sign_in(emailAddress, password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddress,
          password: password
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return false;
    }
  }

   sign_up(email_address, password) async{
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email_address,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email_address,
        'name': email_address.split('@')[0],
      });

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (userDoc.exists) {
        return AppUser.fromFirestore(userDoc);
      }


      return true;
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }

      return false;

    } catch (e) {
      print(e);
      return false;
    }
  }

  sign_out(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/sign_in');
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out. Please try again.")),
      );
    }
  }




}