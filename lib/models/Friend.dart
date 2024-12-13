import '../controllers/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class Friend {
  final String userId;
  final String friendId;
  final String name;
  final String profilePic;
  final int upcomingEvents;
  final String gender ;

  Friend({required this.userId, required this.friendId ,  required this.name, required this.profilePic, required this.upcomingEvents, required this.gender});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
      'name': name,
      'profilePic': profilePic,
      'upcomingEvents': upcomingEvents,
      'gender': gender,


    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
      name: map['name'],
      profilePic: map['profilePic'],
      upcomingEvents: map['upcomingEvents'],
      gender: map['gender'],
    );
  }
  factory Friend.fromFirestore(Map<String, dynamic> data) {
    return Friend(
      friendId: data['friendId'] as String,
      name: data['name'] as String,
      profilePic: data['profilePic'] as String? ?? 'images/3430601_avatar_female_normal_woman_icon.png',
      upcomingEvents: data['upcomingEvents'] as int? ?? 0,
      userId: '',
      gender: data['gender'] as String? ?? 'Male',
    );
  }




}
