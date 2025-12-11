class Game{
  final int? id;
  final int userId;
  final String name;
  final String releaseDate;
  final String description;

  Game({
    this.id,
    required this.userId,
    required this.name,
    required this.releaseDate,
    required this.description
  });

  
}