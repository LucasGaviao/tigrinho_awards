import 'package:sqflite/sqflite.dart';
import '../models/game_genre.dart';
import '../database/db_helper.dart';

class GameGenreRepository {
  //CREATE
  Future<int> createGameGenre(GameGenre game_genre) async {
    final db = await DBHelper().database;

    return await db.insert(
      'game_genre',
      game_genre.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //DELETE
  Future<int> deleteGameGenre(int id) async {
    final db = await DBHelper().database;

    return await db.delete('game_genre', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllGameGenreHavingGameId(int game_Id) async {
    final db = await DBHelper().database;

    return await db.delete(
      'game_genre',
      where: 'game_id = ?',
      whereArgs: [game_Id],
    );
  }

  Future<int> deleteAllGameGenreHavingGenreId(int genre_Id) async {
    final db = await DBHelper().database;

    return await db.delete(
      'game_genre',
      where: 'genre_id = ?',
      whereArgs: [genre_Id],
    );
  }
}
