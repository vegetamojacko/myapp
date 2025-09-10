import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Alex Doe';
  String _email = 'alex.doe@example.com';
  Map<String, dynamic>? _selectedPlan = {
    'name': 'Premium Ticket Insurance',
    'price': r'$49.99/month',
    'benefits': 'Event cancellations, Postponements, and more',
    'dateJoined': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    'amountAvailable': 2500.0,
    'amountUsed': 0.0,
  };

  String get name => _name;
  String get email => _email;
  Map<String, dynamic>? get selectedPlan => _selectedPlan;

  void updateUser({required String name, required String email}) {
    _name = name;
    _email = email;
    notifyListeners();
  }

  void updateSubscription(String name, String price) {
    final amount = double.tryParse(price.replaceAll(r'R', '')) ?? 0.0;
    _selectedPlan = {
      'name': name,
      'price': price,
      'dateJoined': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'amountAvailable': amount,
      'amountUsed': 0.0,
      'benefits': null,
    };
    notifyListeners();
  }

  void updateSelectedPlan(Map<String, dynamic>? plan) {
    _selectedPlan = plan;
    notifyListeners();
  }
}
