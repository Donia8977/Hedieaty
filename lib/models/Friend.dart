import 'DatabaseHelper.dart';

class Friend {
  final String userId;
  final String friendId;
  final String name;
  final String profilePic;
  final int upcomingEvents;

  Friend({required this.userId, required this.friendId ,  required this.name, required this.profilePic, required this.upcomingEvents,});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
      'name': name,
      'profilePic': profilePic,
      'upcomingEvents': upcomingEvents,

    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
      name: map['name'],
      profilePic: map['profilePic'],
      upcomingEvents: map['upcomingEvents'],
    );
  }


  //
  // static Future<List<Friend>> getFriends() async {
  //   final db = await DatabaseHelper().database;
  //   final List<Map<String, dynamic>> maps = await db.query('Friends');
  //   return List.generate(maps.length, (i) => Friend.fromMap(maps[i]));
  // }




  // Future<int> insertFriends(Friend friend) async{
  //
  //   final db = await DatabaseHelper().database;
  //   return await db.insert('Friends', friend.toMap());
  //
  // }
  //
  // Future<Friend?> getFriendById(int id) async {
  //   final db = await DatabaseHelper().database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'Friends',
  //     where: 'friendId = ?',
  //     whereArgs: [id],
  //   );
  //
  //   if (maps.isNotEmpty) {
  //     return Friend.fromMap(maps.first);
  //   } else {
  //     return null;
  //   }
  // }
  //
  //
  // Future<int> updateFriend(Friend friend) async{
  //
  //   final db = await DatabaseHelper().database;
  //   return await db.update('Friends', friend.toMap(), where: 'friendId = ?', whereArgs: [friend.friendId]);
  //
  //
  // }
  //
  // Future<int> deleteEvents(Friend friend) async {
  //   final db = await DatabaseHelper().database;
  //   return await db.delete('Friends', where: 'friendId = ?', whereArgs: [friendId]);
  // }
  //
  //




}
