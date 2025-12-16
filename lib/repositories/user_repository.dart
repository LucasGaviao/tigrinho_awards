import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../database/db_helper.dart';

class UserRepository {

  //CREATE
  Future<int> createUser(User user) async {
    
    final db = await DBHelper().database;

    final exists = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [user.email],
    );

    if(exists.isNotEmpty){
      return -1;
    }

    return await db.insert(
      'user',
      user.toMap(),
    );

  }

  //READ
  Future<List<User>> getAllUsers() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('user');

    return maps.map((mapa) => User.fromMap(mapa)).toList();

  }

  Future<User?> login(String email, String password) async {
    
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if(maps.isNotEmpty){
      return User.fromMap(maps.first);
    }
    else{
      return null;
    }
  }

  //UPDATE
  Future<int> updateUser(User user) async {

    final db = await DBHelper().database;

    if (user.id == null){
      print('Usuário sem ID');
      return 0;
    }

    return await db.update(
      'user',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  //DELETE
  Future<int> deleteUser(int id) async {

    final db = await DBHelper().database;

    return await db.delete(
      'user',
      where: 'id = ?',
      whereArgs: [id],
    );

  }

}