import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _email = 'alex.doe@example.com';
  String _contactNumber = '';
  Map<String, dynamic>? _selectedPlan;

  String get name => _name;
  String get email => _email;
  String get contactNumber => _contactNumber;
  Map<String, dynamic>? get selectedPlan => _selectedPlan;

  void updateUser({required String name, required String email, required String contactNumber}) {
    _name = name;
    _email = email;
    _contactNumber = contactNumber;
    notifyListeners();
  }

  void updateSubscription(String name, String price) {
    final currentAmountAvailable = _selectedPlan?['amountAvailable'] as double? ?? 0.0;
    final currentAmountUsed = _selectedPlan?['amountUsed'] as double? ?? 0.0;
    
    _selectedPlan = {
      'name': name,
      'price': price,
      'benefits': _getBenefitsForPlan(name),
      'dateJoined': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'amountAvailable': currentAmountAvailable,
      'amountUsed': currentAmountUsed,
    };
    notifyListeners();
  }

  String _getBenefitsForPlan(String planName) {
    if (planName == 'Car Wash') {
      return 'Unlimited car washes and detailing';
    }
    return 'Event cancellations, Postponements, and more';
  }

  void updateSelectedPlan(Map<String, dynamic>? plan) {
    _selectedPlan = plan;
    notifyListeners();
  }
}
