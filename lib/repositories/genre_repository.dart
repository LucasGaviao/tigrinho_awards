import 'package:sqflite/sqflite.dart';
import '../models/genre.dart';
import '../database/db_helper.dart';

class GenreRepository {
  //CREATE
  Future<int> insert(Genre genre) async {
    final db = await DBHelper().database;
    return await db.insert('genre', genre.toMap());
  }

  Future<int> createGenre(Genre genre) async {
    final db = await DBHelper().database;

    return await db.insert(
      'genre',
      genre.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //READ
  Future<List<Genre>> getAll() async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('genre');
    return maps.map((mapa) => Genre.fromMap(mapa)).toList();
  }

  Future<List<Genre>> getAllGenres() async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('genre');

    return maps.map((mapa) => Genre.fromMap(mapa)).toList();
  }

  Future<List<Genre>> searchGenresByName(String name) async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'genre',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    return maps.map((mapa) => Genre.fromMap(mapa)).toList();
  }

  Future<Genre?> getById(int id) async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'genre',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Genre.fromMap(maps.first);
    }
    return null;
  }

  //UPDATE
  Future<int> update(Genre genre) async {
    final db = await DBHelper().database;
    return await db.update(
      'genre',
      genre.toMap(),
      where: 'id = ?',
      whereArgs: [genre.id],
    );
  }

  //DELETE
  Future<int> delete(int id) async {
    final db = await DBHelper().database;
    return await db.delete('genre', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGenre(int id) async {
    final db = await DBHelper().database;

    return await db.delete('genre', where: 'id = ?', whereArgs: [id]);
  }
}
