import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/banking_provider.dart';
import '../providers/navigation_provider.dart';

void showBankingDetailsModal(
  BuildContext context,
  String planName,
  String planPrice,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (context, scrollController) => BankingDetailsForm(
        planName: planName,
        planPrice: planPrice,
        scrollController: scrollController,
      ),
    ),
  );
}

class BankingDetailsForm extends StatefulWidget {
  final String planName;
  final String planPrice;
  final ScrollController scrollController;

  const BankingDetailsForm({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.scrollController,
  });

  @override
  State<BankingDetailsForm> createState() => _BankingDetailsFormState();
}

class _BankingDetailsFormState extends State<BankingDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _branchCodeController = TextEditingController();

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _branchCodeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final bankingInfo = BankingInfo(
        accountHolder: _accountHolderController.text,
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        branchCode: _branchCodeController.text,
      );
      context.read<BankingProvider>().updateBankingInfo(bankingInfo);
      Navigator.pop(context); // Close the modal
      context.read<NavigationProvider>().navigateToPage(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.planName} selected!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            Text(
              'Enter Banking Details',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'For ${widget.planName} - ${widget.planPrice}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _accountHolderController,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account holder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(labelText: 'Bank Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bank name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(labelText: 'Account Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branchCodeController,
              decoration: const InputDecoration(labelText: 'Branch Code'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter branch code';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _submitForm, child: const Text('Submit')),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
