import 'package:sqflite/sqflite.dart';
import '../models/category_game.dart';
import '../database/db_helper.dart';



class categoryGameRepository {
  
  Future<int> insert_CatGame(CategoryGame categoryGame ) async {
    
    final db = await DBHelper().database;

    return await db.insert(
      'category_game',
      categoryGame.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

  }

  Future<List<CategoryGame>> getGames() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('category_game');

    return maps.map((mapa) => CategoryGame.fromMap(mapa)).toList();
  }

}


