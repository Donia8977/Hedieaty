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
  String? imageBase64;
  final Map<String, dynamic>? userStatuses;


  Gift({this.id, required this.name, this.description, required this.category, required this.price, required this.status, required this.eventId , required this.friendName ,  this.imageBase64, this.userStatuses,});

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
      'imageBase64': imageBase64,
      'userStatuses': userStatuses,
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {

    if (!map.containsKey('id')) {
      throw ArgumentError('Gift map does not contain an ID.');
    }

    double parsedPrice = 0.0;
    if (map['price'] != null) {
      if (map['price'] is num) {
        parsedPrice = (map['price'] as num).toDouble();
      } else if (map['price'] is String) {
        try {
          parsedPrice = double.parse(map['price']);
        } catch (e) {
          print("Warning: Invalid price format '${map['price']}'. Defaulting to 0.0.");
        }
      }
    }



    return Gift(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price : parsedPrice,
      status: map['status'] ?? 'Available',
      eventId: map['eventId'] ?? '',
      friendName:  '',
      imageBase64: map['imageBase64'] ?? '',
    );
  }



}

// price: map['price']?.toDouble() ?? 0.0,