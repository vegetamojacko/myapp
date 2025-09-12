import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _name = '';
  String _email = '';
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

  void updateSubscription(String planName, double planPrice) {
    _selectedPlan = {
      'name': planName,
      'price': planPrice,
      'date': Timestamp.now(),
    };
    notifyListeners();
    _updatePlanInFirestore();
  }

  Future<void> loadUserData(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['name'] ?? '';
        _email = data['email'] ?? '';
        _contactNumber = data['whatsapp'] ?? '';
        _selectedPlan = data['selectedPlan'];
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error loading user data: $e', name: 'UserProvider');
    }
  }

  void clearUserData() {
    _name = '';
    _email = '';
    _contactNumber = '';
    _selectedPlan = null;
    notifyListeners();
  }

  Future<void> _updatePlanInFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && _selectedPlan != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).set(
          {
            'selectedPlan': _selectedPlan,
          },
          SetOptions(merge: true), // Use merge to avoid overwriting other user data
        );
        developer.log('Successfully updated plan in Firestore for UID: ${currentUser.uid}', name: 'UserProvider');
      } catch (e, s) {
        developer.log(
          'Error updating plan in Firestore for UID: ${currentUser.uid}',
          name: 'UserProvider',
          error: e,
          stackTrace: s,
        );
        // Optionally, handle the error (e.g., show a message to the user)
      }
    }
  }
}
