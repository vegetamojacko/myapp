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

    if (bankingProvider.bankingInfo != null) {
      userProvider.updateSubscription(planName, planPrice);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully changed to $planName!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      userProvider.updateSubscription(planName, planPrice);
      showBankingDetailsModal(context, planName, planPrice);
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
        title: const Text('Subscription Plans'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCarWashSubscription(context, currentPlan,
                bankingProvider.bankingInfo != null),
            const SizedBox(height: 24),
            _buildPricingPlan(
              context,
              title: 'Starter Vibes',
              price: 'R249/month',
              description:
                  'Perfect for students or anyone looking to start small.',
              features: [
                'Claim tickets for events of your choice',
                'Affordable entry into the Candibean experience',
                'Great for concerts, movies, or casual nights out',
              ],
              buttonColor: const Color(0xFF28A745),
              buttonTextColor: Colors.white,
              currentPlan: currentPlan,
              hasBankingDetails: bankingProvider.bankingInfo != null,
            ),
            const SizedBox(height: 24),
            _buildPricingPlan(
              context,
              title: 'Momentum Wave',
              price: 'R349/month',
              description:
                  'For those who want a little more energy and variety.',
              features: [
                'Access to bigger events and more ticket options',
                'Extra flexibility to claim the events you love',
                'Ideal for young professionals and groups of friends',
              ],
              buttonColor: const Color(0xFFFD7E14),
              buttonTextColor: Colors.white,
              currentPlan: currentPlan,
              hasBankingDetails: bankingProvider.bankingInfo != null,
            ),
            const SizedBox(height: 24),
            _buildPricingPlan(
              context,
              title: 'Elite Experience',
              price: 'R549/month',
              description: 'Go all out with the full Candibean lifestyle.',
              features: [
                'Premium access to top-tier events',
                'Bigger savings on high-demand tickets',
                'Tailored for couples, VIP vibes, and event lovers',
              ],
              buttonColor: const Color(0xFF6F42C1),
              buttonTextColor: Colors.white,
              currentPlan: currentPlan,
              hasBankingDetails: bankingProvider.bankingInfo != null,
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('Skip for now'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCarWashSubscription(
      BuildContext context, Map<String, dynamic>? currentPlan, bool hasBankingDetails) {
    const planName = 'Car Wash';
    const planPrice = 'R100/month';
    final isCurrentPlan = currentPlan != null && currentPlan['name'] == planName;
    final planPriceNumber = _parsePrice(planPrice);
    final currentPriceNumber =
        currentPlan != null ? _parsePrice(currentPlan['price']) : 0.0;

    String buttonText;
    VoidCallback? onPressed;

    if (hasBankingDetails) {
      if (isCurrentPlan) {
        buttonText = 'Current Plan';
        onPressed = null;
      } else if (planPriceNumber > currentPriceNumber) {
        buttonText = 'Upgrade';
        onPressed = () => _selectPlan(context, planName, planPrice);
      } else {
        buttonText = 'Downgrade';
        onPressed = () => _selectPlan(context, planName, planPrice);
      }
    } else {
      buttonText = 'Select Plan';
      onPressed = () => _selectPlan(context, planName, planPrice);
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              planName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              planPrice,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Why settle for ordinary when your car can shine like a VIP?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'What’s included:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildFeatureRow(
                'Priority service – your car gets first-class treatment',
                color: Colors.blue),
            _buildFeatureRow('Skip the queue', color: Colors.blue),
            _buildFeatureRow(
                'Eco-friendly products – gentle on your car paint',
                color: Colors.blue),
            _buildFeatureRow(
                'VIP treatment while you wait – relax in comfort, we handle the shine',
                color: Colors.blue),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 18.0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingPlan(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required Color buttonColor,
    required Color buttonTextColor,
    required Map<String, dynamic>? currentPlan,
    required bool hasBankingDetails,
  }) {
    final isCurrentPlan = currentPlan != null && currentPlan['name'] == title;
    final planPriceNumber = _parsePrice(price);
    final currentPriceNumber =
        currentPlan != null ? _parsePrice(currentPlan['price']) : 0.0;

    String buttonText;
    VoidCallback? onPressed;

    if (hasBankingDetails) {
      if (isCurrentPlan) {
        buttonText = 'Current Plan';
        onPressed = null;
      } else if (planPriceNumber > currentPriceNumber) {
        buttonText = 'Upgrade';
        onPressed = () => _selectPlan(context, title, price);
      } else {
        buttonText = 'Downgrade';
        onPressed = () => _selectPlan(context, title, price);
      }
    } else {
      buttonText = 'Select Plan';
      onPressed = () => _selectPlan(context, title, price);
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              price,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 48.0, fontWeight: FontWeight.bold, color: buttonColor),
            ),
            const Text(
              'per month',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 24.0),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 24.0),
            ...features
                .map((feature) => _buildFeatureRow(feature, color: buttonColor)),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 18.0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 16.0))),
        ],
      ),
    );
  }
}
