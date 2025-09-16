import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

  factory BankingInfo.fromJson(Map<dynamic, dynamic> json) => BankingInfo(
    bankName: json['bankName'] ?? '',
    accountNumber: json['accountNumber'] ?? '',
    accountHolder: json['accountHolder'] ?? '',
    branchCode: json['branchCode'],
  );
}

class BankingProvider with ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BankingInfo? _bankingInfo;

  BankingInfo? get bankingInfo => _bankingInfo;

  Future<void> updateBankingInfo(BankingInfo? bankingInfo) async {
    _bankingInfo = bankingInfo;
    notifyListeners();
    await _saveBankingInfoToDatabase();
  }

  Future<void> loadBankingInfo(User user) async {
    try {
      final snapshot = await _database
          .ref('users/${user.uid}/bankingInfo')
          .get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _bankingInfo = BankingInfo.fromJson(data);
        notifyListeners();
      }
    } catch (e, s) {
      developer.log(
        'Error loading banking info: $e',
        name: 'BankingProvider',
        stackTrace: s,
      );
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
        await _database.ref('users/${currentUser.uid}/bankingInfo').remove();
        developer.log(
          'Deleted banking info from Realtime Database for UID: ${currentUser.uid}',
          name: 'BankingProvider',
        );
      } catch (e, s) {
        developer.log(
          'Error deleting banking info from Realtime Database for UID: ${currentUser.uid}',
          name: 'BankingProvider',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  Future<void> _saveBankingInfoToDatabase() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && _bankingInfo != null) {
      try {
        await _database
            .ref('users/${currentUser.uid}/bankingInfo')
            .set(_bankingInfo!.toJson());
        developer.log(
          'Saved banking info to Realtime Database for UID: ${currentUser.uid}',
          name: 'BankingProvider',
        );
      } catch (e, s) {
        developer.log(
          'Error saving banking info to Realtime Database for UID: ${currentUser.uid}',
          name: 'BankingProvider',
          error: e,
          stackTrace: s,
        );
      }
    }
  }
}
