import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../database/db_helper.dart';

class CategoryRepository {
  
  //CREATE
  Future<int> insertCategory(Category category) async {
    
    final db = await DBHelper().database;

    return await db.insert(
      'category',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //READ
  Future<List<Category>> getAllCategories() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('category');

    return maps.map((mapa) => Category.fromMap(mapa)).toList();
  }

  Future<List<Category>> searchCategories(String name) async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'category',
      where: 'title LIKE ?',
      whereArgs: ['%$name%'],
    );

    return maps.map((mapa) => Category.fromMap(mapa)).toList();
  }

  //UPDATE
  Future<int> updateCategory(Category category) async {

    final db = await DBHelper().database;

    if(category.id == null){
      print('Categoria sem ID');
      return 0;
    }

    return await db.update(
      'category',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  //DELETE
  Future<int> deleteCategory(int id) async {

    final db = await DBHelper().database;

    return await db.delete(
      'category',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}