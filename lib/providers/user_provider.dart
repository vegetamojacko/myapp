import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = 'John Doe';
  String _email = 'john.doe@example.com';

  String get name => _name;
  String get email => _email;

  void updateUser({required String name, required String email}) {
    _name = name;
    _email = email;
    notifyListeners();
  }
}
