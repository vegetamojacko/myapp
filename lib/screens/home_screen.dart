
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_state.dart';
import '../models/claim.dart';
import '../providers/banking_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/car_wash_claim_form.dart';
import '../widgets/event_claim_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentActivity(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bankingProvider = Provider.of<BankingProvider>(context);
    final plan = userProvider.selectedPlan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back, ${userProvider.name}!',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (plan != null) ...[
            if (bankingProvider.bankingInfo == null)
              Text(
                'Joined: ${plan['dateJoined'].toString()}',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white70),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Plan: ${plan['name']}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                            context, 'Joined', plan['dateJoined'].toString()),
                      ),
                      Expanded(
                        child: _buildInfoColumn(context, 'Available',
                            'R${plan['amountAvailable'].toStringAsFixed(2)}'),
                      ),
                      Expanded(
                        child: _buildInfoColumn(context, 'Used',
                            'R${plan['amountUsed'].toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                ],
              ),
          ] else ...[
            Text(
              'No active plan.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.white70),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: Colors.white70),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          softWrap: true, // Ensure text wraps
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final plan = userProvider.selectedPlan;
    final hasPlan = plan != null;
    final hasSufficientFunds = hasPlan && plan['amountAvailable'] >= 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionCard(
              context,
              icon: Icons.event,
              label: 'Claim Event',
              onTap: null,
            ),
            _buildActionCard(
              context,
              icon: Icons.directions_car,
              label: 'Claim Car Wash',
              onTap:
                  hasSufficientFunds && hasPlan ? () => _showCarWashClaimSheet(context, claim: null) : null,
            ),
            _buildActionCard(
              context,
              icon: Icons.history,
              label: 'View History',
              onTap: () => context.go('/claims'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.5,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Claims',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        BlocBuilder<ClaimsBloc, ClaimsState>(
          builder: (context, state) {
            if (state is ClaimsLoaded) {
              // Filter for claims that are still pending.
              final pendingClaims = state.claims
                  .where((claim) => claim.status == 'Pending')
                  .toList();

              if (pendingClaims.isNotEmpty) {
                // Take the first 3 pending claims to display.
                final recentClaims = pendingClaims.take(3).toList();
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentClaims.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final claim = recentClaims[index];
                    return _buildRecentClaimItem(context, claim);
                  },
                );
              }
            }
            // If there are no pending claims, show the default message.
            return const Center(child: Text('No recent claims.'));
          },
        ),
      ],
    );
  }

  Widget _buildRecentClaimItem(BuildContext context, Claim claim) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          claim.isCarWashClaim ? Icons.wash : Icons.event,
          color: Colors.white,
        ),
      ),
      title: Text(claim.isCarWashClaim ? 'Car Wash Claim' : claim.eventName!),
      subtitle: Text('Status: ${claim.status}'),
      trailing: Text(
        'R${claim.totalAmount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () => context.read<NavigationProvider>().navigateToPage(1),
    );
  }

  void _showAddClaimSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ClaimsBloc>(),
          child: const EventClaimForm(),
        );
      },
    );
  }

  void _showCarWashClaimSheet(BuildContext context, {required Claim? claim}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ClaimsBloc>(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: CarWashClaimForm(claim: claim),
            ),
          ),
        );
      },
    );
  }
}
