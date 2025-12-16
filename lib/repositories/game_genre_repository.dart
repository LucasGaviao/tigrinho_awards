import '../database/db_helper.dart';
import '../models/game_genre.dart';

class GameGenreRepository {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert(GameGenre gameGenre) async {
    final db = await _dbHelper.database;
    return await db.insert('game_genre', gameGenre.toMap());
  }

  Future<List<GameGenre>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('game_genre');
    return List.generate(maps.length, (i) => GameGenre.fromMap(maps[i]));
  }

  Future<List<GameGenre>> getGameGenres() async {
    return await getAll();
  }

  Future<int> createGameGenre(GameGenre gameGenre) async {
    return await insert(gameGenre);
  }

  Future<int> deleteGameGenre(int gameId, int genreId) async {
    return await delete(gameId, genreId);
  }

  Future<List<GameGenre>> getByGameId(int gameId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_genre',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    return List.generate(maps.length, (i) => GameGenre.fromMap(maps[i]));
  }

  Future<List<GameGenre>> getByGenreId(int genreId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_genre',
      where: 'genre_id = ?',
      whereArgs: [genreId],
    );
    return List.generate(maps.length, (i) => GameGenre.fromMap(maps[i]));
  }

  Future<int> delete(int gameId, int genreId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'game_genre',
      where: 'game_id = ? AND genre_id = ?',
      whereArgs: [gameId, genreId],
    );
  }

  Future<int> deleteByGameId(int gameId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'game_genre',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
  }
}
