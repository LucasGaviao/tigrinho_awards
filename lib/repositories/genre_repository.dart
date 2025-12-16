import 'package:sqflite/sqflite.dart';
import 'package:tigrinho_awards/repositories/game_genre_repository.dart';
import '../models/genre.dart';
import '../database/db_helper.dart';
import 'category_game_repository.dart';

class GenreRepository {
  // CREATE
  Future<int> createGenre(Genre genre) async {
    final db = await DBHelper().database;

    return await db.insert(
      'genre',
      genre.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - ALL
  Future<List<Genre>> getAllGenres() async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('genre');

    return maps.map(Genre.fromMap).toList();
  }

  // READ - SEARCH BY NAME
  Future<List<Genre>> searchGenresByName(String name) async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'genre',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    return maps.map(Genre.fromMap).toList();
  }

  // READ - BY ID (ÚTIL PARA EDITAR)
  Future<Genre?> getGenreById(int id) async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'genre',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Genre.fromMap(maps.first);
  }

  // UPDATE
  Future<int> updateGenre(Genre genre) async {
    final db = await DBHelper().database;

    if (genre.id == null) return 0;

    return await db.update(
      'genre',
      genre.toMap(),
      where: 'id = ?',
      whereArgs: [genre.id],
    );
  }

  // DELETE
  Future<int> deleteGenre(int id) async {
    final db = await DBHelper().database;

    final _gameGenreRepo = GameGenreRepository();

    await _gameGenreRepo.deleteAllGameGenreHavingGenreId(id);

    return await db.delete('genre', where: 'id = ?', whereArgs: [id]);
  }
}
