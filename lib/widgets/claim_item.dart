import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/claim.dart';

class ClaimItem extends StatelessWidget {
  final Claim claim;

  const ClaimItem({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    final eventDate = DateFormat.yMMMd().format(claim.eventDate);
    final submittedDate = DateFormat.yMMMd().format(DateTime.parse(claim.submittedDate)); // Corrected: Parse String to DateTime

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 400;
          if (isWide) {
            return _buildWideLayout(currencyFormat, eventDate, submittedDate);
          } else {
            return _buildNarrowLayout(currencyFormat, eventDate, submittedDate);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(NumberFormat currencyFormat, String eventDate, String submittedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                claim.eventName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Event on $eventDate • Submitted on $submittedDate',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${claim.numTickets} ticket(s) at ${currencyFormat.format(claim.ticketCost)} each',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Text(
              currencyFormat.format(claim.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 12),
            Chip(
              label: const Text('Pending'),
              backgroundColor: const Color(0xFFfef9c3),
              labelStyle: const TextStyle(
                color: Color(0xFF713f12),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(NumberFormat currencyFormat, String eventDate, String submittedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          claim.eventName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Event on $eventDate • Submitted on $submittedDate',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '${claim.numTickets} ticket(s) at ${currencyFormat.format(claim.ticketCost)} each',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currencyFormat.format(claim.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Chip(
              label: const Text('Pending'),
              backgroundColor: const Color(0xFFfef9c3),
              labelStyle: const TextStyle(
                color: Color(0xFF713f12),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ],
        ),
      ],
    );
  }
}
