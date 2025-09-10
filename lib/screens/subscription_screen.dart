import 'package:flutter/material.dart';

import '../widgets/subscription_card.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            SubscriptionCard(
              title: 'Starter Vibes',
              price: 'R249/month',
              features: [
                'Claim tickets for events of your choice',
                'Affordable entry into the Candibean experience',
                'Great for concerts, movies, or casual nights out',
              ],
              color: Colors.blue,
            ),
            SubscriptionCard(
              title: 'Momentum Wave',
              price: 'R349/month',
              features: [
                'Access to bigger events and more ticket options',
                'Extra flexibility to claim the events you love',
                'Ideal for young professionals and groups of friends',
              ],
              color: Colors.purple,
            ),
            SubscriptionCard(
              title: 'Elite Experience',
              price: 'R549/month',
              features: [
                'Premium access to top-tier events',
                'Bigger savings on high-demand tickets',
                'Tailored for couples, VIP vibes, and event lovers',
              ],
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}
