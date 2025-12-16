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
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'date': date,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
    );
  }
}
