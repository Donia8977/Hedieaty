import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hedieaty/controllers/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';



class AppEvent {

  final String id;
  final String name;
  final String date;
  final String? location;
  final String? description;
  final String userId;
  final String status;
  final String category;

  AppEvent({required this.id, required this.name, required this.date, this.location, this.description,
    required this.userId , required this.status , required this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
      'status': status,
      'category' : category,
    };
  }

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    return AppEvent(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      userId: map['userId'],
      status: map['status'],
      category: map['category'],

    );
  }


  factory AppEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppEvent(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? '',
      location: data['location'],
      date: data['date'] ?? '',
      userId: data['userId'] ?? '',
    );
  }


}