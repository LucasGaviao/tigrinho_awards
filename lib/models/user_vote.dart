class UserVote {
  final int? id;
  final int userId;
  final int categoryId;
  final int gameId;

  UserVote({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.gameId
  });

}