import '../database/db_helper.dart';
import '../models/user_vote.dart';

class UserVoteRepository {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert(UserVote vote) async {
    final db = await _dbHelper.database;
    return await db.insert('user_vote', vote.toMap());
  }

  Future<List<UserVote>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('user_vote');
    return List.generate(maps.length, (i) => UserVote.fromMap(maps[i]));
  }

  Future<UserVote?> getByUserAndCategory(int userId, int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_vote',
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
    );
    if (maps.isEmpty) return null;
    return UserVote.fromMap(maps.first);
  }

  Future<int> update(UserVote vote) async {
    final db = await _dbHelper.database;
    return await db.update(
      'user_vote',
      vote.toMap(),
      where: 'id = ?',
      whereArgs: [vote.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('user_vote', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteByUserAndCategory(int userId, int categoryId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'user_vote',
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
    );
  }

  // Get vote count for each game in a category
  Future<Map<int, int>> getVoteCountsByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT vote_game_id, COUNT(*) as vote_count
      FROM user_vote
      WHERE category_id = ?
      GROUP BY vote_game_id
    ''',
      [categoryId],
    );

    Map<int, int> voteCounts = {};
    for (var row in result) {
      voteCounts[row['vote_game_id']] = row['vote_count'];
    }
    return voteCounts;
  }
}
