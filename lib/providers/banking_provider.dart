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
  StreamSubscription? _selectedPlanSubscription;

  BankingInfo? get bankingInfo => _bankingInfo;
  double get amountUsed => _amountUsed;
  double get amountAvailable => _amountAvailable;
  bool get isClaimingDisabled => _amountAvailable <= 0.0;

  Future<void> updateBankingInfo(BankingInfo? bankingInfo) async {
    _bankingInfo = bankingInfo;
    notifyListeners();
    await _saveBankingInfo(bankingInfo);
  }

  Future<void> loadBankingInfo(User user) async {
    try {
      final bankingRef = _database.ref('users/${user.uid}/bankingInfo');
      final bankingSnapshot = await bankingRef.get();
      if (bankingSnapshot.exists) {
        final data = bankingSnapshot.value as Map<dynamic, dynamic>;
        _bankingInfo = BankingInfo.fromJson(data);
        notifyListeners();
      }
    } catch (e, s) {
      developer.log('Error loading banking info: $e', name: 'BankingProvider', stackTrace: s);
    }
  }

  void listenToUserChanges(User user) {
    listenToClaims(user);
    listenToSelectedPlan(user);
  }

  void listenToClaims(User user) {
    _claimsSubscription?.cancel();
    final claimsRef = _database.ref('users/${user.uid}/claims');

    _claimsSubscription = claimsRef.onValue.listen((event) {
      double newTotalApprovedAmount = 0;
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value;
        if (data is List) {
          final claims = data
              .where((item) => item != null && item is Map)
              .map((item) => Claim.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
          for (var claim in claims) {
            if (claim.status == 'Approved') {
              newTotalApprovedAmount += claim.totalAmount;
            }
          }
        } else if (data is Map) {
          final claims = data.values
              .where((item) => item != null && item is Map)
              .map((item) => Claim.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          for (var claim in claims) {
            if (claim.status == 'Approved') {
              newTotalApprovedAmount += claim.totalAmount;
            }
          }
        }
      }
      _runBalanceTransaction(user.uid, newTotalApprovedAmount);
    });
  }

  Future<void> _runBalanceTransaction(String uid, double newTotalApprovedAmount) async {
    final planRef = _database.ref('users/$uid/selectedPlan');
    try {
      await planRef.runTransaction((Object? mutableData) {
        if (mutableData == null) {
          return Transaction.abort();
        }

        final Map<String, dynamic> planData = Map<String, dynamic>.from(mutableData as Map);

        final bool isInitialized = planData.containsKey('amountUsed') && planData.containsKey('amountAvailable');

        double totalPlanValue = 0.0;

        if (!isInitialized) {
          final double price = (planData['price'] as num?)?.toDouble() ?? 0.0;
          if (price <= 0) {
            return Transaction.abort();
          }
          totalPlanValue = price * 12;
          planData['amountUsed'] = 0.0;
          planData['amountAvailable'] = totalPlanValue;
        } 

        final double serverAmountUsed = (planData['amountUsed'] as num?)?.toDouble() ?? 0.0;

        if (serverAmountUsed == newTotalApprovedAmount) {
          return Transaction.success(planData);
        }

        if (isInitialized) {
            final double serverAmountAvailable = (planData['amountAvailable'] as num?)?.toDouble() ?? 0.0;
            totalPlanValue = serverAmountAvailable + serverAmountUsed;
        } 

        final double newAvailableAmount = totalPlanValue - newTotalApprovedAmount;

        planData['amountUsed'] = newTotalApprovedAmount;
        planData['amountAvailable'] = newAvailableAmount;

        return Transaction.success(planData);
      });
    } catch (e) {
        developer.log('Transaction failed: $e', name: 'BankingProvider');
    }
  }

  void listenToSelectedPlan(User user) {
    _selectedPlanSubscription?.cancel();
    final selectedPlanRef = _database.ref('users/${user.uid}/selectedPlan');
    _selectedPlanSubscription = selectedPlanRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final newAmountAvailable = (data['amountAvailable'] as num?)?.toDouble() ?? 0.0;
        final newAmountUsed = (data['amountUsed'] as num?)?.toDouble() ?? 0.0;

        if (_amountAvailable != newAmountAvailable || _amountUsed != newAmountUsed) {
          _amountAvailable = newAmountAvailable;
          _amountUsed = newAmountUsed;
          notifyListeners();
        }
      } else {
        if (_amountAvailable != 0.0 || _amountUsed != 0.0) {
          _amountAvailable = 0.0;
          _amountUsed = 0.0;
          notifyListeners();
        }
      }
    });
  }

  void clearBankingInfo() {
    _bankingInfo = null;
    _amountAvailable = 0.0;
    _amountUsed = 0.0;
    _claimsSubscription?.cancel();
    _selectedPlanSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _claimsSubscription?.cancel();
    _selectedPlanSubscription?.cancel();
    super.dispose();
  }

  Future<void> _saveBankingInfo(BankingInfo? bankingInfo) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && bankingInfo != null) {
      try {
        await _database.ref('users/${currentUser.uid}/bankingInfo').set(bankingInfo.toJson());
      } catch (e, s) {
        developer.log('Error saving banking info for UID: ${currentUser.uid}', name: 'BankingProvider', error: e, stackTrace: s);
      }
    }
  }
}
