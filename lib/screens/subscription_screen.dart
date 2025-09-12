import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/banking_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/banking_details_modal.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  void _selectPlan(BuildContext context, String planName, String planPrice) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bankingProvider = Provider.of<BankingProvider>(context, listen: false);
    final price = _parsePrice(planPrice);

    if (bankingProvider.bankingInfo != null) {
      userProvider.updateSubscription(planName, price);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully changed to $planName!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      userProvider.updateSubscription(planName, price);
      showBankingDetailsModal(context, planName, price.toString());
    }
  }

  double _parsePrice(String priceString) {
    final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bankingProvider = Provider.of<BankingProvider>(context);
    final currentPlan = userProvider.selectedPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              context,
              'Basic Plan',
              'R150/month',
              ['5 Claims', 'Up to R500 per claim', 'Email support'],
              currentPlan?['name'] == 'Basic Plan',
              bankingProvider.bankingInfo != null,
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              context,
              'Premium Plan',
              'R300/month',
              ['Unlimited Claims', 'Up to R2000 per claim', '24/7 support'],
              currentPlan?['name'] == 'Premium Plan',
              bankingProvider.bankingInfo != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String planName, String planPrice,
      List<String> features, bool isCurrentPlan, bool hasBankingInfo) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              planPrice,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ...features.map((feature) => Text('• $feature')),
            const SizedBox(height: 20),
            isCurrentPlan
                ? const Chip(
                    label: Text('Current Plan'),
                    backgroundColor: Colors.green,
                  )
                : ElevatedButton(
                    onPressed: () => _selectPlan(context, planName, planPrice),
                    child: const Text('Choose Plan'),
                  ),
          ],
        ),
      ),
    );
  }
}
