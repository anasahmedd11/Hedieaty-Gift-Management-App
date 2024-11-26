import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseClass {
  static Database? _MyDataBase;

  Future<Database?> get MyDataBase async {
    if (_MyDataBase == null) {
      _MyDataBase = await initialize();
      return _MyDataBase;
    } else {
      return _MyDataBase;
    }
  }

  int version = 1;

  Future<Database> initialize() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'HedieatyProjectv16.db');

    Database mydb = await openDatabase(path, version: 1, readOnly: false,onCreate: (db, version) async {
      // Create Users table
      await db.execute('''
      CREATE TABLE IF NOT EXISTS Users (
        ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        Name TEXT NOT NULL,
        Email TEXT NOT NULL,
        ProfilePic TEXT NOT NULL,
        PhoneNumber INTEGER NOT NULL,
        Preferences TEXT
      )
    ''');

      // Create Events table
      await db.execute('''
      CREATE TABLE IF NOT EXISTS Events (
        ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        Name TEXT NOT NULL,
        Date TEXT NOT NULL,
        Location TEXT,
        Status TEXT,
        Description TEXT,
        UserID INTEGER,
        FOREIGN KEY(UserID) REFERENCES Users(ID)
      )
    ''');

      // Create Gifts table
      await db.execute('''
      CREATE TABLE IF NOT EXISTS Gifts (
        ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        Name TEXT NOT NULL,
        Description TEXT NOT NULL,
        Category TEXT NOT NULL,
        Price REAL NOT NULL,
        GiftPic TEXT NOT NULL,
        Status TEXT,
        isLocked INTEGER,
        isPledged INTEGER DEFAULT 0,
        EventID INTEGER,
        FOREIGN KEY(EventID) REFERENCES Events(ID) 
      )
    ''');

      // Create Friends table
      await db.execute('''
      CREATE TABLE IF NOT EXISTS Friends (
        UserID INTEGER NOT NULL,
        FriendID INTEGER NOT NULL,
        PRIMARY KEY(UserID, FriendID),
        FOREIGN KEY(UserID) REFERENCES Users(ID),
        FOREIGN KEY(FriendID) REFERENCES Users(ID)
      )
    ''');


      print("Database version $version has been created with required tables.");
    });

    return mydb;
  }

  // Delete the database
  Future<void> deleteDatabaseFile() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'hedieaty.db');

    try {
      await deleteDatabase(path);
      print("Database deleted successfully");
    } catch (e) {
      print("Error deleting database: $e");
    }
  }


  readData(String SQL) async {
    Database? mydata = await MyDataBase;
    var response = await mydata!.rawQuery(SQL);
    return response;
  }

  insertData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawInsert(SQL);
    return response;
  }

  deleteData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawDelete(SQL);
    return response;
  }

  updateData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawUpdate(SQL);
    return response;
  }

}
