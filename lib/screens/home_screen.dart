import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_state.dart';
import '../widgets/add_claim_form.dart';
import '../widgets/claim_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f4f6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 960;
              if (isWideScreen) {
                return _buildWideScreenLayout(context);
              } else {
                return _buildNarrowScreenLayout(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWideScreenLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildUserProfileCard(),
                  const SizedBox(height: 32.0),
                  _buildPlanCard(),
                ],
              ),
            ),
            const SizedBox(width: 32.0),
            Expanded(
              flex: 2,
              child: _buildClaimsSection(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24.0),
        _buildUserProfileCard(),
        const SizedBox(height: 32.0),
        _buildPlanCard(),
        const SizedBox(height: 32.0),
        _buildClaimsSection(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          "Here's your personal dashboard.",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfileCard() {
    return DashboardCard(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFF6366f1),
                child: Text('U', style: TextStyle(fontSize: 32, color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alex Doe',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600, // Corrected: semibold
                      color: Colors.grey[900],
                    ),
                  ),
                  Text(
                    'alex.doe@example.com',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildInfoRow('Member Since:', 'Jan 15, 2024'),
          const SizedBox(height: 8),
          _buildInfoRow('Location:', 'Midrand, South Africa'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4b5563))),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(color: Color(0xFF4b5563))),
      ],
    );
  }

  Widget _buildPlanCard() {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Plan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[900]), // Corrected: semibold
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Premium Ticket Insurance',
                style: TextStyle(
                  color: Color(0xFF4f46e5),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Chip(
                label: const Text('Active'),
                backgroundColor: const Color(0xFFe0e7ff),
                labelStyle: const TextStyle(
                  color: Color(0xFF3730a3),
                  fontSize: 12,
                  fontWeight: FontWeight.w500, // Corrected: medium
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You are covered for event cancellations, postponements, and more. Enjoy peace of mind with your premium plan.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              child: const Text('Manage Plan', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF4f46e5))), // Corrected: medium
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsSection(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Claims',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[900]), // Corrected: semibold
              ),
              ElevatedButton(
                onPressed: () => _showAddClaimSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4f46e5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Make a Claim', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 16),
          BlocBuilder<ClaimsBloc, ClaimsState>(
            builder: (context, state) {
              if (state is ClaimsLoaded) {
                if (state.claims.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(
                      child: Text(
                        'You have no pending claims.\nClick "Make a Claim" to start.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.claims.length,
                  itemBuilder: (context, index) {
                    final claim = state.claims[index];
                    return ClaimItem(claim: claim);
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  void _showAddClaimSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ClaimsBloc>(),
          child: const AddClaimForm(),
        );
      },
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Widget child;
  const DashboardCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // Corrected: withOpacity deprecated
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
