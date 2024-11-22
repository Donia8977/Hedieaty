import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User _user = User(name: 'John Doe', email: 'john@example.com');

  User get user => _user;

  void updateUser(String name, String email, bool notificationsEnabled) {
    _user = User(name: name, email: email, notificationsEnabled: notificationsEnabled);
    notifyListeners();
  }
}






