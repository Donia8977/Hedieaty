import '../controllers/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class Gift{

  final String? id;
  late  String name;
  late String? description;
  late  String category;
  late double price;
  late  String status;
  final String eventId;
  late String friendName;


  Gift({this.id, required this.name, this.description, required this.category, required this.price, required this.status, required this.eventId , required this.friendName});

  void updateStatus(String newStatus) {
    status = newStatus;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name,
      'description': description ?? '',
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
      'friendName': friendName,
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {

    if (!map.containsKey('id')) {
      throw ArgumentError('Gift map does not contain an ID.');
    }


    return Gift(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Available',
      eventId: map['eventId'] ?? '',
      friendName:  '',
    );
  }



}