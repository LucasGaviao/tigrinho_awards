import 'package:sqflite/sqflite.dart';
import '../models/game.dart';
import '../database/db_helper.dart';
import 'category_game_repository.dart';

class GameRepository {
  
  //CREATE
  Future<int> createGame(Game game) async {
    
    final db = await DBHelper().database;

    return await db.insert(
      'game',
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //READ
  Future<List<Game>> getAllGames() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('game');

    return maps.map((mapa) => Game.fromMap(mapa)).toList();
  }

  Future<List<Game>> searchGamesByName(String name) async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'game',
      where: 'name LIKE ?',   
      whereArgs: ['%$name%'],   
    );

    return maps.map((mapa) => Game.fromMap(mapa)).toList();
  }

  Future<List<Game>> searchGamesById(int id) async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'game',
      where: 'id = ?',   
      whereArgs: [id],   
    );

    return maps.map((mapa) => Game.fromMap(mapa)).toList();
  }


  //UPDATE
  Future<int> updateGame(Game game) async {

    final db = await DBHelper().database;

    if(game.id == null){
      print('Jogo sem ID');
      return 0;
    }

    return await db.update(
      'game',
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id]
    );

  } 

  //DELETE
  Future<int> deleteGame(int id) async {
    
    final db = await DBHelper().database;

    final _categoryGameRepo = CategoryGameRepository();

    await _categoryGameRepo.deleteAllCatGameHavingGameId(id);

    return await db.delete(
      'game',
      where: 'id = ?',
      whereArgs: [id],
    );

  }

}