
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
              title: '🌱 Starter Vibes',
              price: 'R249/month',
              features: [
                'Perfect for students or anyone looking to start small.',
                'Claim tickets for events of your choice',
                'Affordable entry into the Candibean experience',
                'Great for concerts, movies, or casual nights out',
              ],
              color: Colors.blue,
            ),
            SubscriptionCard(
              title: '🌊 Momentum Wave',
              price: 'R349/month',
              features: [
                'For those who want a little more energy and variety.',
                'Access to bigger events and more ticket options',
                'Extra flexibility to claim the events you love',
                'Ideal for young professionals and groups of friends',
              ],
              color: Colors.purple,
            ),
            SubscriptionCard(
              title: '🌟 Elite Experience',
              price: 'R549/month',
              features: [
                'Go all out with the full Candibean lifestyle.',
                'Premium access to top-tier events',
                'Bigger savings on high-demand tickets',
                'Tailored for couples, VIP vibes, and event lovers',
              ],
              color: Colors.amber,
            ),
            SubscriptionCard(
              title: 'CAR Wash',
              price: 'R100/month',
              features: [
                'Why settle for ordinary when your car can shine like a VIP?',
                'Priority service – your car gets first-class treatment',
                'Skip the queue – no more waiting in long lines',
                'Eco-friendly products – gentle on your car, safe for the planet',
                'VIP treatment while you wait – relax in comfort, we handle the shine',
              ],
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
