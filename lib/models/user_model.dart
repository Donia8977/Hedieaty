class User {
  String name;
  String email;
  bool notificationsEnabled;

  User({
    required this.name,
    required this.email,
    this.notificationsEnabled = true,
  });
}