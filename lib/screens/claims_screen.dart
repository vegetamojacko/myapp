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

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});

  @override
  _ClaimsScreenState createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

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
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<ClaimsBloc, ClaimsState>(
              builder: (context, state) {
                if (state is ClaimsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ClaimsError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is ClaimsLoaded) {
                  final List<Claim> filteredClaims = state.claims.where((claim) {
                    final query = _searchQuery.toLowerCase();

                    final String? claimName = claim.isCarWashClaim ? claim.carWashName : claim.eventName;
                    final nameMatch = claimName?.toLowerCase().contains(query) ?? false;
                    
                    final dateMatch = claim.submittedDate.toLowerCase().contains(query);
                    final statusMatch = claim.status.toLowerCase().contains(query);
                    
                    return nameMatch || dateMatch || statusMatch;
                  }).toList();

                  if (state.claims.isEmpty) {
                    return const Center(child: Text('You have no claims. Add one!'));
                  }

                  if (filteredClaims.isEmpty && _searchQuery.isNotEmpty) {
                    return const Center(child: Text('No claims found matching your search.'));
                  }

                  final pendingClaims = filteredClaims
                      .where((claim) => claim.status.toLowerCase() == 'pending')
                      .toList();
                  final completedClaims = filteredClaims
                      .where((claim) =>
                          claim.status.toLowerCase() == 'approved' ||
                          claim.status.toLowerCase() == 'cancelled' ||
                          claim.status.toLowerCase() == 'completed' ||
                          claim.status.toLowerCase() == 'failed')
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      if (pendingClaims.isNotEmpty) ...[
                        _buildSectionTitle(context, 'Pending Claims'),
                        _buildClaimsList(context, pendingClaims),
                      ],
                      if (completedClaims.isNotEmpty) ...[
                        if (pendingClaims.isNotEmpty) const SizedBox(height: 10),
                        _buildSectionTitle(context, 'History'),
                        _buildClaimsList(context, completedClaims),
                      ],
                    ],
                  );
                } else {
                  return const Center(child: Text('You have no claims.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, date, or status...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildClaimsList(BuildContext context, List<Claim> claims) {
    if (claims.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: claims.length,
        itemBuilder: (ctx, index) {
          final claim = claims[index];
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
