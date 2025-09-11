
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_state.dart';
import '../models/claim.dart';
import '../widgets/add_claim_form.dart';
import '../widgets/claim_item.dart';

class ClaimsScreen extends StatelessWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddClaimSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<ClaimsBloc, ClaimsState>(
        builder: (context, state) {
          if (state is ClaimsLoaded) {
            final pendingClaims = state.claims
                .where((claim) => claim.status == 'Pending')
                .toList();
            final completedClaims = state.claims
                .where((claim) =>
                    claim.status == 'Approved' || claim.status == 'Cancelled')
                .toList();

            return ListView(
              children: [
                _buildSectionTitle('Pending Claims'),
                _buildClaimsList(context, pendingClaims),
                const SizedBox(height: 20),
                _buildSectionTitle('History (Last 3)'),
                _buildClaimsList(context, completedClaims, isHistory: true),
              ],
            );
          }
          return const Center(
            child: Text('You have no claims.'),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildClaimsList(BuildContext context, List<Claim> claims, {bool isHistory = false}) {
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
                  child: ClaimItem(
                    claim: claim,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddClaimSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: BlocProvider.of<ClaimsBloc>(context),
          child: const AddClaimForm(),
        );
      },
    );
  }
}
