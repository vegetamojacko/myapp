import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_state.dart';
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
          if (state is ClaimsLoaded && state.claims.isNotEmpty) {
            return AnimationLimiter(
              child: ListView.builder(
                itemCount: state.claims.length,
                itemBuilder: (ctx, index) {
                  final claim = state.claims[index];
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
          return const Center(
            child: Text('You have no pending claims.'),
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
