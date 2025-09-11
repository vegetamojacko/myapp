import 'package:flutter/material.dart';

class BankingInfo {
  final String bankName;
  final String accountNumber;
  final String accountHolder;

  BankingInfo({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });
}

class BankingProvider with ChangeNotifier {
  BankingInfo? _bankingInfo;

  BankingInfo? get bankingInfo => _bankingInfo;

  void updateBankingInfo(BankingInfo? info) {
    _bankingInfo = info;
    notifyListeners();
  }
}
