
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppColors.pendingBackground;
        textColor = AppColors.pendingText;
        break;
      case 'completed':
        backgroundColor = AppColors.completedBackground;
        textColor = AppColors.completedText;
        break;
      case 'failed':
        backgroundColor = AppColors.failedBackground;
        textColor = AppColors.failedText;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Chip(
      label: Text(
        toBeginningOfSentenceCase(status) ?? '',
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
