class Category {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String date;

  Category({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date
  });
  
}
