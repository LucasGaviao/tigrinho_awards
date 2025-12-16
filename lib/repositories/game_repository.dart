import 'package:sqflite/sqflite.dart';
import '../models/game.dart';
import '../database/db_helper.dart';

class GameRepository {
  
  Future<int> insertGame(Game game) async {
    
    final db = await DBHelper().database;

    return await db.insert(
      'game',
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Game>> getGames() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('game');

    return maps.map((mapa) => Game.fromMap(mapa)).toList();
  }

}