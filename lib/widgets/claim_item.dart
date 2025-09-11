import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_event.dart';
import '../models/claim.dart';
import 'car_wash_claim_form.dart';
import 'event_claim_form.dart';

class ClaimItem extends StatelessWidget {
  final Claim claim;

  const ClaimItem({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    String submittedDate;
    try {
      submittedDate =
          DateFormat.yMMMd().format(DateTime.parse(claim.submittedDate));
    } catch (e) {
      submittedDate = 'Invalid Date';
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  claim.isCarWashClaim ? 'Car Wash Claim' : claim.eventName!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                currencyFormat.format(claim.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildClaimDetails(context, submittedDate),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(),
              if (claim.status == 'Pending')
                Row(
                  children: [
                    TextButton(
                        onPressed: () => _showEditSheet(context, claim),
                        child: const Text('Edit')),
                    TextButton(
                        onPressed: () => context
                            .read<ClaimsBloc>()
                            .add(UpdateClaim(claim.copyWith(status: 'Cancelled'))),
                        child: const Text('Cancel')),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClaimDetails(BuildContext context, String submittedDate) {
    if (claim.isCarWashClaim) {
      final washDate = claim.washDate != null
          ? DateFormat.yMMMd().format(claim.washDate!)
          : 'N/A';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wash on $washDate • Submitted on $submittedDate',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${claim.washType} for ${claim.vehicleReg}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      );
    } else {
      final eventDate = claim.eventDate != null
          ? DateFormat.yMMMd().format(claim.eventDate!)
          : 'N/A';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event on $eventDate • Submitted on $submittedDate',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${claim.numTickets} ticket(s) at ${claim.ticketCost} each',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      );
    }
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String text = claim.status;

    switch (claim.status) {
      case 'Approved':
        backgroundColor = const Color(0xFFdcfce7);
        textColor = const Color(0xFF166534);
        break;
      case 'Cancelled':
        backgroundColor = const Color(0xFFfee2e2);
        textColor = const Color(0xFF991b1b);
        break;
      case 'Pending':
      default:
        backgroundColor = const Color(0xFFfef9c3);
        textColor = const Color(0xFF713f12);
        break;
    }

    return Chip(
      label: Text(text),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _showEditSheet(BuildContext context, Claim claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ClaimsBloc>(),
          child: claim.isCarWashClaim
              ? CarWashClaimForm(claim: claim)
              : EventClaimForm(claim: claim),
        );
      },
    );
  }
}
