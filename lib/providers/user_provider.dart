import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Alex Doe';
  String _email = 'alex.doe@example.com';
  Map<String, String?>? _selectedPlan = {
    'name': 'Premium Ticket Insurance',
    'price': r'$49.99/month',
    'benefits': 'Event cancellations, Postponements, and more',
  };

  String get name => _name;
  String get email => _email;
  Map<String, String?>? get selectedPlan => _selectedPlan;

  void updateUser({required String name, required String email}) {
    _name = name;
    _email = email;
    notifyListeners();
  }

  void updateSubscription(String name, String price) {
    _selectedPlan = {
      'name': name,
      'price': price,
      'benefits': null, // Benefits are not specified in the new plans
    };
    notifyListeners();
  }

  void updateSelectedPlan(Map<String, String?>? plan) {
    _selectedPlan = plan;
    notifyListeners();
  }
}
