import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class BankingInfo {
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String? branchCode;

  BankingInfo({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    this.branchCode,
  });

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolder': accountHolder,
        'branchCode': branchCode,
      };

  factory BankingInfo.fromJson(Map<String, dynamic> json) => BankingInfo(
        bankName: json['bankName'] ?? '',
        accountNumber: json['accountNumber'] ?? '',
        accountHolder: json['accountHolder'] ?? '',
        branchCode: json['branchCode'],
      );
}

class BankingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BankingInfo? _bankingInfo;

  BankingInfo? get bankingInfo => _bankingInfo;

  Future<void> updateBankingInfo(BankingInfo? bankingInfo) async {
    _bankingInfo = bankingInfo;
    notifyListeners();
    await _saveBankingInfoToFirestore();
  }

  Future<void> loadBankingInfo(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('bankingInfo')) {
        final data = doc.data()!['bankingInfo'];
        _bankingInfo = BankingInfo.fromJson(data);
        notifyListeners();
      }
    } catch (e, s) {
      developer.log('Error loading banking info: $e', name: 'BankingProvider', stackTrace: s);
    }
  }

  void clearBankingInfo() {
    _bankingInfo = null;
    notifyListeners();
  }

  Future<void> deleteBankingInfo() async {
    _bankingInfo = null;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'bankingInfo': FieldValue.delete(),
        });
        developer.log('Deleted banking info from Firestore for UID: ${currentUser.uid}', name: 'BankingProvider');
      } catch (e, s) {
        developer.log(
          'Error deleting banking info from Firestore for UID: ${currentUser.uid}',
          name: 'BankingProvider',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  Future<void> _saveBankingInfoToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && _bankingInfo != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).set(
          {
            'bankingInfo': _bankingInfo!.toJson(),
          },
          SetOptions(merge: true),
        );
        developer.log('Saved banking info to Firestore for UID: ${currentUser.uid}', name: 'BankingProvider');
      } catch (e, s) {
        developer.log(
          'Error saving banking info to Firestore for UID: ${currentUser.uid}',
          name: 'BankingProvider',
          error: e,
          stackTrace: s,
        );
      }
    }
  }
}
