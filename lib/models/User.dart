import 'DatabaseHelper.dart';

class User{

  final String? id;
  late final String name;
  late final String email;
  final String? preferences;
  late final bool notificationsEnabled;

  User({this.id, required this.name, required this.email, this.preferences , this.notificationsEnabled = true});

  Map<String , dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      preferences: map['preferences'],
      notificationsEnabled: map['notificationsEnabled']?? true,
    );
  }

//The crud operations :

  // Future<int> insertUsers(User user) async{
  //
  //   final db = await DatabaseHelper().database;
  //   return await db.insert('Users', user.toMap());
  //
  // }
  //
  // Future<User?> getUserById(int id) async {
  //   final db = await DatabaseHelper().database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'Users',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  //
  //   if (maps.isNotEmpty) {
  //     return User.fromMap(maps.first);
  //   } else {
  //     return null;
  //   }
  // }
  //
  // Future<int> updateUesrs(User user) async{
  //
  //   final db = await DatabaseHelper().database;
  //   return await db.update('Users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  //
  //
  // }
  //
  // Future<int> deleteUser(User user) async {
  //   final db = await DatabaseHelper().database;
  //   return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  // }



}