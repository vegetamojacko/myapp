import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import 'package:myapp/blocs/claims/claims_bloc.dart';
import 'package:myapp/blocs/claims/claims_state.dart';
import 'package:myapp/models/claim.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/widgets/claim_item.dart';
import 'package:myapp/widgets/event_claim_form.dart';
import 'package:myapp/widgets/car_wash_claim_form.dart';

class ClaimsScreen extends StatelessWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final selectedPlan = userProvider.selectedPlan;
    final bool isCarWashPlan = selectedPlan?['name'] == 'Car Wash';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                isCarWashPlan ? null : () => _showAddClaimDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ClaimsBloc, ClaimsState>(
        builder: (context, state) {
          if (state is ClaimsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClaimsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ClaimsLoaded) {
            if (state.claims.isEmpty) {
              return const Center(child: Text('You have no claims. Add one!'));
            }
            final pendingClaims = state.claims
                .where((claim) => claim.status.toLowerCase() == 'pending')
                .toList();
            final completedClaims = state.claims
                .where(
                  (claim) =>
                      claim.status.toLowerCase() == 'approved' ||
                      claim.status.toLowerCase() == 'cancelled' ||
                      claim.status.toLowerCase() == 'completed' ||
                      claim.status.toLowerCase() == 'failed',
                )
                .toList();

            return ListView(
              children: [
                _buildSectionTitle(context, 'Pending Claims'),
                _buildClaimsList(context, pendingClaims),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'History (Last 3)'),
                _buildClaimsList(context, completedClaims, isHistory: true),
              ],
            );
          } else {
            return const Center(child: Text('You have no claims.'));
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildClaimsList(
    BuildContext context,
    List<Claim> claims, {
    bool isHistory = false,
  }) {
    if (claims.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No claims in this category.'),
        ),
      );
    }

    final itemsToShow = isHistory ? claims.take(3).toList() : claims;

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemsToShow.length,
        itemBuilder: (ctx, index) {
          final claim = itemsToShow[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ClaimItem(claim: claim),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddClaimDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Claim Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Event Claim'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _showClaimForm(context, isCarWash: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_car_wash),
                title: const Text('Car Wash Claim'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _showClaimForm(context, isCarWash: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClaimForm(BuildContext context,
      {required bool isCarWash, Claim? claim}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: BlocProvider.of<ClaimsBloc>(context),
          child: isCarWash
              ? CarWashClaimForm(claim: claim)
              : EventClaimForm(claim: claim),
        );
      },
    );
  }
}
