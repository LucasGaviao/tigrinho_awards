class User{
  final int? id;
  final String name;
  final String email;
  final String? password;
  final bool role;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role
  });

}