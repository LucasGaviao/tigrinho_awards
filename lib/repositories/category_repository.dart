import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../database/db_helper.dart';

class CategoryRepository {
  
  Future<int> insertCategory(Category category) async {
    
    final db = await DBHelper().database;

    return await db.insert(
      'category',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Category>> getCategories() async {

    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('category_game');

    return maps.map((mapa) => Category.fromMap(mapa)).toList();
  }

}