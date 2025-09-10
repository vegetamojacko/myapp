import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPricingPlan(
                  context,
                  title: 'Starter Vibes',
                  price: 'R249',
                  description: 'Perfect for students or anyone looking to start small.',
                  features: [
                    'Claim tickets for events of your choice',
                    'Affordable entry into the Candibean experience',
                    'Great for concerts, movies, or casual nights out',
                  ],
                  buttonColor: const Color(0xFF28A745),
                  buttonTextColor: Colors.white,
                ),
                const SizedBox(height: 24),
                _buildPricingPlan(
                  context,
                  title: 'Momentum Wave',
                  price: 'R349',
                  description: 'For those who want a little more energy and variety.',
                  features: [
                    'Access to bigger events and more ticket options',
                    'Extra flexibility to claim the events you love',
                    'Ideal for young professionals and groups of friends',
                  ],
                  buttonColor: const Color(0xFFFD7E14),
                  buttonTextColor: Colors.white,
                ),
                const SizedBox(height: 24),
                _buildPricingPlan(
                  context,
                  title: 'Elite Experience',
                  price: 'R549',
                  description: 'Go all out with the full Candibean lifestyle.',
                  features: [
                    'Premium access to top-tier events',
                    'Bigger savings on high-demand tickets',
                    'Tailored for couples, VIP vibes, and event lovers',
                  ],
                  buttonColor: const Color(0xFF6F42C1),
                  buttonTextColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPricingPlan(BuildContext context, {
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required Color buttonColor,
    required Color buttonTextColor,
  }) {
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
              style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: buttonColor),
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
            ...features.map((feature) => _buildFeatureRow(feature, buttonColor)),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('Select Plan', style: TextStyle(fontSize: 18.0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, Color checkmarkColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check, color: checkmarkColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 16.0))),
        ],
      ),
    );
  }
}
