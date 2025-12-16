import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../database/db_helper.dart';

class UserRepository {

  //CREATE
  Future<int> createUser(User user) async {
    
    final db = await DBHelper().database;

    return await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

  }

  //READ
  Future<List<User>> getAllUsers() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('user');

    return maps.map((mapa) => User.fromMap(mapa)).toList();

  }

  //UPDATE
  Future<List<User>> updateUser(int id) async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('user');

    return maps.map((mapa) => User.fromMap(mapa)).toList();

  }
}