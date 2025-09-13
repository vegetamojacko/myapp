
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/user_provider.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final Color color;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    required this.color,
  });

  double _parsePrice(String priceString) {
    final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentPlan = userProvider.selectedPlan;
    final isNewUser = currentPlan == null;
    final isCurrentPlan = currentPlan != null && currentPlan['name'] == title;
    final planPriceNumber = _parsePrice(price);
    final currentPriceNumber = currentPlan != null ? (currentPlan['price'] ?? 0.0) as double : 0.0;

    String buttonText;
    if (isNewUser) {
      buttonText = 'Select Plan';
    } else if (isCurrentPlan) {
      buttonText = 'Current Plan';
    } else if (planPriceNumber > currentPriceNumber) {
      buttonText = 'Upgrade';
    } else {
      buttonText = 'Downgrade';
    }

    return Card(
      color: color.withAlpha(26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: color, width: 2),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 20),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  children: [
                    Icon(Icons.check, color: color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isCurrentPlan
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Subscription'),
                            content: Text(
                                'Do you want to subscribe to the $title plan?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Provider.of<UserProvider>(context, listen: false)
                                      .updateSubscription(title, price);

                                  Navigator.of(context).pop();
                                  if (isNewUser) {
                                    context.go('/banking-details');
                                  } else {
                                    navigatorKey.currentState
                                        ?.popUntil((route) => route.isFirst);
                                  }
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
