import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/banking_provider.dart';

class BankingDetailsScreen extends StatefulWidget {
  const BankingDetailsScreen({super.key});

  @override
  State<BankingDetailsScreen> createState() => _BankingDetailsScreenState();
}

class _BankingDetailsScreenState extends State<BankingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountHolderController;
  late TextEditingController _branchCodeController;

  @override
  void initState() {
    super.initState();
    final bankingProvider = Provider.of<BankingProvider>(context, listen: false);
    final bankingInfo = bankingProvider.bankingInfo;
    _bankNameController = TextEditingController(text: bankingInfo?.bankName ?? '');
    _accountNumberController =
        TextEditingController(text: bankingInfo?.accountNumber ?? '');
    _accountHolderController =
        TextEditingController(text: bankingInfo?.accountHolder ?? '');
    _branchCodeController =
        TextEditingController(text: bankingInfo?.branchCode ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banking Details'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the bank name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(labelText: 'Account Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the account number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _accountHolderController,
                  decoration:
                      const InputDecoration(labelText: 'Account Holder Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the account holder name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _branchCodeController,
                  decoration: const InputDecoration(labelText: 'Branch Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the branch code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final bankingInfo = BankingInfo(
                        bankName: _bankNameController.text,
                        accountNumber: _accountNumberController.text,
                        accountHolder: _accountHolderController.text,
                        branchCode: _branchCodeController.text,
                      );
                      final router = GoRouter.of(context);
                      context
                          .read<BankingProvider>()
                          .updateBankingInfo(bankingInfo)
                          .then((_) {
                        if (mounted) {
                          router.go('/home');
                        }
                      });
                    }
                  },
                  child: const Text('Save Banking Details'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
