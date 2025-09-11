import 'package:flutter/material.dart';

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
}

class BankingProvider with ChangeNotifier {
  BankingInfo? _bankingInfo;

  BankingInfo? get bankingInfo => _bankingInfo;

  void updateBankingInfo(BankingInfo? bankingInfo) {
    _bankingInfo = bankingInfo;
    notifyListeners();
  }
}
