
import 'package:sqflite/sqflite.dart'; 
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tigrinho_awards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('Rota: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE genre(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE game(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name VARCHAR NOT NULL UNIQUE,
        description TEXT NOT NULL,
        release_date VARCHAR NOT NULL,
        FOREIGN KEY(user_id) REFERENCES user(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE game_genre(
        game_id INTEGER NOT NULL,
        genre_id INTEGER NOT NULL,
        FOREIGN KEY(game_id) REFERENCES game(id),
        FOREIGN KEY(genre_id) REFERENCES genre(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE category(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title VARCHAR NOT NULL,
        description TEXT,  
        date VARCHAR NOT NULL,
        FOREIGN KEY(user_id) REFERENCES user(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE category_game(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        game_id INTEGER NOT NULL,
        FOREIGN KEY(category_id) REFERENCES category(id),
        FOREIGN KEY(game_id) REFERENCES game(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_vote(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        vote_game_id INTEGER NOT NULL,    
        FOREIGN KEY(user_id) REFERENCES user(id),
        FOREIGN KEY(category_id) REFERENCES category(id),
        FOREIGN KEY(vote_game_id) REFERENCES category_game(game_id)
      ) 
    ''');
    
  }
}