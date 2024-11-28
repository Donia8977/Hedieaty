import 'DatabaseHelper.dart';

class Gift{

  final String? id;
  late final String name;
  final String? description;
  late final String category;
  final double price;
  late final String status;
  final String eventId;

  Gift({this.id, required this.name, this.description, required this.category, required this.price, required this.status, required this.eventId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      eventId: map['eventId'],
    );
  }



  // Future<int> insertGifts(Gift gift) async{
  //
  //   final db = await DatabaseHelper().database;
  //   return await db.insert('Gifts', gift.toMap());
  //
  // }
  //
  // Future<Gift?> getGiftById(int id) async {
  //   final db = await DatabaseHelper().database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'Gifts',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  //
  //   if (maps.isNotEmpty) {
  //     return Gift.fromMap(maps.first);
  //   } else {
  //     return null;
  //   }
  // }

  //
  // Future<int> updateEvents(Gift gift) async{
  //
  //   final db = await DatabaseHelper().database;
  //   return await db.update('Gifts', gift.toMap(), where: 'id = ?', whereArgs: [gift.id]);
  //
  //
  // }
  //
  // Future<int> deleteEvents(Gift gift) async {
  //   final db = await DatabaseHelper().database;
  //   return await db.delete('Gifts', where: 'id = ?', whereArgs: [id]);
  // }











}