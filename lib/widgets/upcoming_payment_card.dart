import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../utils/constants.dart';

class UpcomingPaymentCard extends StatelessWidget {
  final Subscription subscription;

  const UpcomingPaymentCard({super.key, required this.subscription});

  Color _urgencyColor(BuildContext context, int days) {
    if (days == 0) return Colors.red;
    if (days <= 1) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  String _urgencyLabel(int days) {
    if (days == 0) return 'Due Today';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }

  @override
  Widget build(BuildContext context) {
    final days = subscription.daysUntilBilling;
    final urgencyColor = _urgencyColor(context, days);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: urgencyColor.withValues(alpha: 0.15),
          child: Text(
            AppConstants.categoryIcons[subscription.category] ?? '📦',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          subscription.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${subscription.currency} ${subscription.cost.toStringAsFixed(2)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _urgencyLabel(days),
            style: TextStyle(
              color: urgencyColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
