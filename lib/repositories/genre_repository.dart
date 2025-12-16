import 'package:sqflite/sqflite.dart';
import '../models/genre.dart';
import '../database/db_helper.dart';

class GameRepository {
  
  //CREATE
  Future<int> createGenre(Genre genre) async {
    
    final db = await DBHelper().database;

    return await db.insert(
      'genre',
      genre.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //READ
  Future<List<Genre>> getAllGenres() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('genre');

    return maps.map((mapa) => Genre.fromMap(mapa)).toList();
  }

  Future<List<Genre>> searchGamesByName(String name) async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'genre',
      where: 'name LIKE ?',   
      whereArgs: ['%$name%'],   
    );

    return maps.map((mapa) => Genre.fromMap(mapa)).toList();
  }

  /*
  Future<List<Game>> searchGamesById(int id) async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'game',
      where: 'id = ?',   
      whereArgs: [id],   
    );

    return maps.map((mapa) => Game.fromMap(mapa)).toList();
  }
  */

  //DELETE
  Future<int> deleteGame(int id) async {
    
    final db = await DBHelper().database;

    //final _gameGenreRepo = GenreGameRepository();

    //await _gameGenreRepo.deleteAllGameGenreHavingGenreId(id);

    return await db.delete(
      'game',
      where: 'id = ?',
      whereArgs: [id],
    );

  }

}