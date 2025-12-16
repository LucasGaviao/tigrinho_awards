import 'package:sqflite/sqflite.dart';
import '../models/category_game.dart';
import '../database/db_helper.dart';
import '../models/game.dart';

class CategoryGameRepository {
  
  //CREATE
  Future<int> createCatGame(CategoryGame categoryGame ) async {
    
    final db = await DBHelper().database;

    return await db.insert(
      'category_game',
      categoryGame.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //READ
  Future<List<CategoryGame>> getCatGames() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('category_game');

    return maps.map((mapa) => CategoryGame.fromMap(mapa)).toList();
  }

  Future<List<Game>> searchCatGames(String categoryName) async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT game.* FROM game
      INNER JOIN category_game on game.id = category_game.game_id
      INNER JOIN category on category_game.category_id = category.id
      WHERE category.title LIKE ?
    ''', ['%$categoryName%']);
  
    return maps.map((mapa) => Game.fromMap(mapa)).toList();

  }

  //DELETE
  Future<int> deleteCatGame(int id) async {

    final db = await DBHelper().database;

    return await db.delete(
      'category_game',
      where: 'id = ?',
      whereArgs: [id],
    );

  }

  Future<int> deleteAllCatGameHavingGameId(int gameId) async {

    final db = await DBHelper().database;

    return await db.delete(
      'category_game',
      where: 'gameId = ?',
      whereArgs: [gameId],
    );

  }

}


