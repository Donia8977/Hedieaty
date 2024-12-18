import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hedieaty/models/Friend.dart';
import 'package:hedieaty/models/AppUser.dart';
import 'package:hedieaty/models/Event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../main.dart';
import '../models/Gift.dart';

const String fileName = "hedieaydb2.db";

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();


  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initializeDB(fileName);
    return _database!;
  }

// Future<void> deleteDatabaseFile() async {
//    String dbPath = await getDatabasesPath();
//    String path = join(dbPath, fileName);
//
//    try {
//     await deleteDatabase(path);
//     _database = null;
//     print("Database deleted successfully.");
//    } catch (e) {
//     print("Error deleting database: $e");
//    }
//   }

  Future<Database> _initializeDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        id TEXT PRIMARY KEY, 
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        preferences TEXT
      );
      ''');

    await db.execute('''
  CREATE TABLE Friends (
        userId TEXT NOT NULL, 
        friendId TEXT NOT NULL, 
        name TEXT NOT NULL,
        profilePic TEXT NOT NULL,
        upcomingEvents INTEGER NOT NULL,
        PRIMARY KEY (userId, friendId),
        FOREIGN KEY (userId) REFERENCES Users (id),
        FOREIGN KEY (friendId) REFERENCES Users (id)
  );
  ''');

    await db.execute('''
      CREATE TABLE Events (
         id TEXT PRIMARY KEY, 
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        userId TEXT,
        category TEXT,
        status TEXT,
        FOREIGN KEY (userId) REFERENCES Users (id)
      );
    ''');



    await db.execute('''
      CREATE TABLE Gifts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT,
        eventId TEXT, 
        FOREIGN KEY (eventId) REFERENCES Events (id)
      );
    ''');

    await db.execute(
      '''
      CREATE TABLE PledgedGifts(
          id TEXT PRIMARY KEY,             
          userId TEXT NOT NULL,          
          giftId TEXT NOT NULL,            
          friendId TEXT NOT NULL,  
           eventId TEXT NOT NULL,        
          FOREIGN KEY (userId) REFERENCES Users (id),  
          FOREIGN KEY (giftId) REFERENCES Gifts (id),    
          FOREIGN KEY (friendId) REFERENCES Users (id)
          FOREIGN KEY (eventId) REFERENCES Events (id)

      );


     '''
    );

  }

  static Future<List<Friend>> getFriends() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('Friends');
    return List.generate(maps.length, (i) => Friend.fromMap(maps[i]));
  }

  Future<int> insertFriend(Friend friend) async {
    final db = await database;
    return await db.insert(
      'Friends',
      friend.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }



  Future<int> updateFriend(Friend friend) async {
    final db = await DatabaseHelper().database;
    return await db.update('Friends', friend.toMap(),
        where: 'friendId = ?', whereArgs: [friend.friendId]);
  }

  Future<int> deleteFriend(Friend friend) async {
    final db = await DatabaseHelper().database;
    return await db
        .delete('Friends', where: 'friendId = ?', whereArgs: [friend.friendId]);
  }



///////////////////////////////////////////////////////////////

  Future<int> addEvents(AppEvent event) async {
    final db = await database;
    return await db.insert(
      'Events',
      event.toMap(),
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  static Future<List<AppEvent>> getEvents() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('Events');
    return List.generate(maps.length, (i) => AppEvent.fromMap(maps[i]));
  }


  Future<int> updateEvent(AppEvent event) async {
    final db = await database;
    return await db.update(
      'Events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(String eventId) async {
    final db = await database;
    return await db.delete(
      'Events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }
////////////////////////////////////////////////////////////

  Future<int> insertUsers(AppUser user) async{

    final db = await DatabaseHelper().database;
    return await db.insert('Users', user.toMap());

  }

  static Future<List<AppUser>> getUsers() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('Users');
    return List.generate(maps.length, (i) => AppUser.fromMap(maps[i]));
  }

  Future<int> updateUesrs(AppUser user) async{

    final db = await DatabaseHelper().database;
    return await db.update('Users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);


  }

  Future<int> deleteUser(AppUser user) async {
    final db = await DatabaseHelper().database;
    return await db.delete('Users', where: 'id = ?', whereArgs: [user.id]);
  }


///////////////////////////////////////////////////

  Future<List<Gift>> getGifts(String eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Gifts', where: 'eventId =?', whereArgs: [eventId]);

    // for (var map in maps) {
    //   print("Gift ID: ${map['id']}, Name: ${map['name']}");
    // }

    print(maps);

    return List.generate(maps.length, (i) => Gift.fromMap(maps[i]));
  }

  Future<int> insertGift(Gift gift) async {

    print('Inserting Gift into DB: ${gift.toMap()}');

    final db = await database;
    return await db.insert(
      'Gifts',
      gift.toMap(),
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<int> updateGift(Gift gift) async {
    final db = await database;

    try {
      if (gift.id == null) {
        throw ArgumentError("Gift ID cannot be null");
      }

      return await db.update(
        'Gifts',
        gift.toMap(),
        where: 'id =?',
        whereArgs: [gift.id],
      );
    } catch (e) {
      print('Error updating gift: $e');
      return 0;
    }
  }


  Future<int> deleteGift(Gift gift) async {
    final db = await database;
    return await db.delete('Gifts', where: 'id =?', whereArgs: [gift.id]);
  }


  static Future<List<Gift>> getPledgedGiftsByUserId(String userId) async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'PledgedGifts',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Gift.fromMap(map)).toList();
  }

  static Future<List<AppEvent>> getEventsByUserId(String userId) async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'Events',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return maps.map((map) => AppEvent.fromMap(map)).toList();
  }


//////////////////////////////////////

  Future<List<Map<String, dynamic>>> getPledgedGiftsByFriendAndUser(String userId, String friendId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'PledgedGifts',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );

    return maps;
  }


  Future<int> insertPledgedGift({
    required String id,
    required String userId,
    required String friendId,
    required String giftId,
    required String eventId,
  }) async {
    final db = await database;

    final pledgedGift = {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'giftId': giftId,
      'eventId': eventId,
    };

    return await db.insert(
      'PledgedGifts',
      pledgedGift,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updatePledgedGift({
    required String id,
    required String userId,
    required String friendId,
    required String giftId,
    required String eventId,
  }) async {
    final db = await database;

    final pledgedGift = {
      'userId': userId,
      'friendId': friendId,
      'giftId': giftId,
      'eventId': eventId,
    };

    return await db.update(
      'PledgedGifts',
      pledgedGift,
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future<List<Map<String, dynamic>>> getGiftsPledgedToFriendByUser(String userId, String friendId) async {
    final db = await database;

    return await db.rawQuery('''
    SELECT pg.id AS pledgedGiftId, g.name AS giftName, g.description AS giftDescription
    FROM PledgedGifts pg
    JOIN Gifts g ON pg.giftId = g.id
    WHERE pg.userId = ? AND pg.friendId = ?
  ''', [userId, friendId]);
  }






}
