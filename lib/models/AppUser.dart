import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class AppUser{

  final String? id;
   String? name;
   String? email;
   String? phoneNumber;
  String? profilePic;
   bool notificationsEnabled;

  AppUser({this.id, required this.name, required this.email, this.phoneNumber ,  this.profilePic, this.notificationsEnabled = true});

  Map<String , dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': phoneNumber,
      'profilePic': profilePic,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profilePic: map['profilePic'],
      notificationsEnabled: map['notificationsEnabled']?? true,
    );

  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] as String?,
      email: data['email'] as String?,
      profilePic: data['profilePic'] as String?,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? false,
    );
  }



}