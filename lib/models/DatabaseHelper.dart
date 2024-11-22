import 'package:hedieaty/models/User.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String fileName= "app_database.db";

class DatabaseHelper{

  // DatabaseHelper._init();
  //
  // static final DatabaseHelper instance = DatabaseHelper._init();
  //
  // static Database? _database;

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async{

    if(_database != null){
      return _database!;
    }

    _database = await _initializeDB(fileName);
    return _database!;

  }



}

Future<Database> _initializeDB(String fileName) async {

  final dbpath = await getDatabasesPath();
  final path = join(dbpath, fileName);
  return await openDatabase(path,version: 1 ,onCreate: _createDB);




}

Future _createDB (Database db , int version) async{

  await db.execute('''
  CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        preferences TEXT
      );
 
  ''');


  await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES Users (id)
      );
    ''');

  await db.execute('''
      CREATE TABLE Gifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT,
        eventId INTEGER,
        FOREIGN KEY (eventId) REFERENCES Events (id)
      );
    ''');

  await db.execute('''
      CREATE TABLE Friends (
        userId INTEGER,
        friendId INTEGER,
        PRIMARY KEY (userId, friendId),
        FOREIGN KEY (userId) REFERENCES Users (id),
        FOREIGN KEY (friendId) REFERENCES Users (id)
      );
    ''');


  // Future<int> insertUsers(User user) async{
  //
  //  final db = await DatabaseHelper().database;
  //  return await db.insert('Users', user.toMap());
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
  //     return null; // Return null if no user is found
  //   }
  // }



}