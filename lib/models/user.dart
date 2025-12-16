class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final int role; // 0 = admin, 1 = common user

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
  });

  bool get isAdmin => role == 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }
}
