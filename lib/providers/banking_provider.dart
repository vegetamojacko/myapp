
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../models/claim.dart';

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
  StreamSubscription<DatabaseEvent>? _claimsSubscription;

  BankingInfo? _bankingInfo;
  double _amountAvailable = 0.0;
  double _amountUsed = 0.0;
  double _initialAmountAvailable = 0.0;


  BankingInfo? get bankingInfo => _bankingInfo;
  double get amountUsed => _amountUsed;
  double get amountAvailable => _amountAvailable;
  bool get isClaimingDisabled => _amountAvailable <= 0.0;

  Future<void> updateBankingInfo(BankingInfo? bankingInfo) async {
    _bankingInfo = bankingInfo;
    notifyListeners();
    await _saveBankingInfo();
  }

  Future<void> updateAmountsOnClaim({
    required double oldClaimAmount,
    required double newClaimAmount,
  }) async {
    _amountUsed = _amountUsed - oldClaimAmount + newClaimAmount;
    _amountAvailable = _amountAvailable + oldClaimAmount - newClaimAmount;
    notifyListeners();
    await _updateSelectedPlan();
  }

  Future<void> loadBankingInfo(User user) async {
    try {
      final bankingRef = _database.ref('users/${user.uid}/bankingInfo');
      final selectedPlanRef = _database.ref('users/${user.uid}/selectedPlan'); // Corrected path

      final bankingSnapshot = await bankingRef.get();
      if (bankingSnapshot.exists) {
        final data = bankingSnapshot.value as Map<dynamic, dynamic>;
        _bankingInfo = BankingInfo.fromJson(data);
      }

      final selectedPlanSnapshot = await selectedPlanRef.get();
      if (selectedPlanSnapshot.exists) {
        final data = selectedPlanSnapshot.value as Map<dynamic, dynamic>;
        // Use 'amountAvailable' from DB which is the total budget initially
        _initialAmountAvailable = (data['amountAvailable'] as num?)?.toDouble() ?? 0.0;
        _amountUsed = (data['amountUsed'] as num?)?.toDouble() ?? 0.0;
        _amountAvailable = _initialAmountAvailable - _amountUsed;
      }
      listenToClaims(user);
      notifyListeners();
    } catch (e, s) {
      developer.log(
        'Error loading banking info and selected plan: $e',
        name: 'BankingProvider',
        stackTrace: s,
      );
    }
  }

  void listenToClaims(User user) {
    _claimsSubscription?.cancel();
    final claimsRef = _database.ref('users/${user.uid}/claims');
    _claimsSubscription = claimsRef.onValue.listen((event) async {
      if (event.snapshot.exists) {
        final claimsData = event.snapshot.value as Map<dynamic, dynamic>;
        final claims = claimsData.entries.map((e) {
          final claimData = Map<String, dynamic>.from(e.value as Map);
          claimData['id'] = e.key;
          return Claim.fromMap(claimData);
        }).toList();

        double totalApprovedAmount = 0;
        for (var claim in claims) {
          if (claim.status == 'Approved') {
            totalApprovedAmount += claim.totalAmount;
          }
        }

        _amountUsed = totalApprovedAmount;
        _amountAvailable = _initialAmountAvailable - _amountUsed;

        await _updateSelectedPlan();
        notifyListeners();
      }
    });
  }


  void clearBankingInfo() {
    _bankingInfo = null;
    _amountAvailable = 0.0;
    _amountUsed = 0.0;
    _claimsSubscription?.cancel();
    notifyListeners();
  }

  Future<void> deleteBankingInfo() async {
    _bankingInfo = null;
    _amountAvailable = 0.0;
    _amountUsed = 0.0;
    notifyListeners();

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _database.ref('users/${currentUser.uid}/bankingInfo').remove();
        // Also clear the amounts in the selectedPlan, but don't remove the whole plan
        await _database.ref('users/${currentUser.uid}/selectedPlan').update({
          'amountAvailable': _initialAmountAvailable,
          'amountUsed': 0
        });
        developer.log(
          'Deleted banking info and reset plan amounts for UID: ${currentUser.uid}',
          name: 'BankingProvider',
        );
      } catch (e, s) {
        developer.log(
          'Error deleting banking info for UID: ${currentUser.uid}',
          name: 'BankingProvider',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  Future<void> _saveBankingInfo() async {
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

  // Renamed and corrected to update the selectedPlan node
  Future<void> _updateSelectedPlan() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _database
            .ref('users/${currentUser.uid}/selectedPlan')
            .update({
          'amountAvailable': _initialAmountAvailable,
          'amountUsed': _amountUsed,
        });
        developer.log(
          'Updated selected plan amounts in Realtime Database for UID: ${currentUser.uid}',
          name: 'BankingProvider',
        );
      } catch (e, s) {
        developer.log(
          'Error updating selected plan amounts for UID: ${currentUser.uid}',
          name: 'BankingProvider',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  @override
  void dispose() {
    _claimsSubscription?.cancel();
    super.dispose();
  }
}
