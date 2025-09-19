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

  BankingInfo? _bankingInfo;
  double _amountAvailable = 0.0;
  double _amountUsed = 0.0;
  StreamSubscription? _claimsSubscription;
  bool _isInitialClaimsLoad = true;

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
    _isInitialClaimsLoad = true; // Reset flag on new user load
    try {
      final bankingRef = _database.ref('users/${user.uid}/bankingInfo');
      final selectedPlanRef = _database.ref('users/${user.uid}/selectedPlan');

      final bankingSnapshot = await bankingRef.get();
      if (bankingSnapshot.exists) {
        final data = bankingSnapshot.value as Map<dynamic, dynamic>;
        _bankingInfo = BankingInfo.fromJson(data);
      }

      final selectedPlanSnapshot = await selectedPlanRef.get();
      if (selectedPlanSnapshot.exists) {
        final data = selectedPlanSnapshot.value as Map<dynamic, dynamic>;
        _amountAvailable = (data['amountAvailable'] as num?)?.toDouble() ?? 0.0;
        _amountUsed = (data['amountUsed'] as num?)?.toDouble() ?? 0.0;
      }
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
      if (_isInitialClaimsLoad) {
        _isInitialClaimsLoad = false;
        return; // Do not run calculation on initial load
      }

      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value;
        List<Claim> claims = [];
        if (data is List) {
          claims = data
              .where((item) => item != null && item is Map)
              .map((item) =>
                  Claim.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        } else if (data is Map) {
          for (final item in data.values) {
            if (item != null && item is Map) {
              try {
                claims.add(Claim.fromJson(Map<String, dynamic>.from(item)));
              } catch (e) {
                developer.log('Error parsing a claim from map: $e');
              }
            }
          }
        }

        double newTotalApprovedAmount = 0;
        for (var claim in claims) {
          if (claim.status == 'Approved') {
            newTotalApprovedAmount += claim.totalAmount;
          }
        }

        final double delta = newTotalApprovedAmount - _amountUsed;

        if (delta == 0) {
          return; // No changes in approved claims, so do nothing.
        }

        _amountUsed += delta;
        _amountAvailable -= delta;

        await _updateSelectedPlan();
        notifyListeners();
      }
    });
  }

  void clearBankingInfo() {
    _bankingInfo = null;
    _amountAvailable = 0.0;
    _amountUsed = 0.0;
    _isInitialClaimsLoad = true;
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
        await _database
            .ref('users/${currentUser.uid}/selectedPlan')
            .update({'amountAvailable': 0, 'amountUsed': 0});
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

  @override
  void dispose() {
    _claimsSubscription?.cancel();
    super.dispose();
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

  Future<void> _updateSelectedPlan() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _database.ref('users/${currentUser.uid}/selectedPlan').update({
          'amountAvailable': _amountAvailable,
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
}
