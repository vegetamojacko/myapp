import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class UserProvider with ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _name = '';
  String _email = '';
  String _contactNumber = '';
  Map<String, dynamic>? _selectedPlan;

  String get name => _name;
  String get email => _email;
  String get contactNumber => _contactNumber;
  Map<String, dynamic>? get selectedPlan => _selectedPlan;

  void updateUser({
    required String name,
    required String email,
    required String contactNumber,
  }) {
    _name = name;
    _email = email;
    _contactNumber = contactNumber;
    notifyListeners();
    _updateUserInDatabase();
  }

  double _parsePrice(String priceString) {
    final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  void setSubscription(String planName, String planPriceString) {
    final double newPlanPrice = _parsePrice(planPriceString);

    // Preserve existing financial data, only update plan name and price.
    _selectedPlan = {
      'name': planName,
      'price': newPlanPrice,
      'dateJoined': _selectedPlan?['dateJoined'] ?? ServerValue.timestamp,
      'amountAvailable': (_selectedPlan?['amountAvailable'] as num?)?.toDouble() ?? 0.0,
      'amountUsed': (_selectedPlan?['amountUsed'] as num?)?.toDouble() ?? 0.0,
    };
    notifyListeners();
  }

  void updateSubscription(String planName, String planPriceString) {
    setSubscription(planName, planPriceString);
    _updatePlanInDatabase();
  }

  Future<void> loadUserData(User user) async {
    try {
      final snapshot = await _database.ref('users/${user.uid}').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _name = data['name'] ?? '';
        _email = data['email'] ?? '';
        _contactNumber = data['whatsapp'] ?? '';

        if (data['selectedPlan'] != null) {
          final plan = data['selectedPlan'] as Map<dynamic, dynamic>;
          _selectedPlan = {
            'name': plan['name'],
            'price': (plan['price'] as num?)?.toDouble() ?? 0.0,
            'dateJoined': plan['dateJoined'],
            'amountAvailable':
                (plan['amountAvailable'] as num?)?.toDouble() ?? 0.0,
            'amountUsed': (plan['amountUsed'] as num?)?.toDouble() ?? 0.0,
          };
        } else {
          _selectedPlan = null;
        }

        notifyListeners();
      }
    } catch (e, s) {
      developer.log(
        'Error loading user data: $e',
        name: 'UserProvider',
        stackTrace: s,
      );
    }
  }

  void clearUserData() {
    _name = '';
    _email = '';
    _contactNumber = '';
    _selectedPlan = null;
    notifyListeners();
  }

  Future<void> _updateUserInDatabase() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _database.ref('users/${currentUser.uid}').update({
          'name': _name,
          'email': _email,
          'whatsapp': _contactNumber,
        });
        developer.log(
          'Successfully updated user in Realtime Database for UID: ${currentUser.uid}',
          name: 'UserProvider',
        );
      } catch (e, s) {
        developer.log(
          'Error updating user in Realtime Database for UID: ${currentUser.uid}',
          name: 'UserProvider',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  Future<void> _updatePlanInDatabase() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && _selectedPlan != null) {
      try {
        await _database
            .ref('users/${currentUser.uid}/selectedPlan')
            .set(_selectedPlan);
        developer.log(
          'Successfully updated plan in Realtime Database for UID: ${currentUser.uid}',
          name: 'UserProvider',
        );
      } catch (e, s) {
        developer.log(
          'Error updating plan in Realtime Database for UID: ${currentUser.uid}',
          name: 'UserProvider',
          error: e,
          stackTrace: s,
        );
      }
    }
  }
}
