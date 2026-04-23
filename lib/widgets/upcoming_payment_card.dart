import 'package:flutter/material.dart';
import '../models/subscription.dart';
import 'subscription_logo.dart';

class UpcomingPaymentCard extends StatelessWidget {
  final Subscription subscription;

  const UpcomingPaymentCard({super.key, required this.subscription});

  Color _urgencyColor(BuildContext context, int days) {
    if (days == 0) return const Color(0xFFEF4444); // Modern Red
    if (days <= 1) return const Color(0xFFF59E0B); // Modern Amber
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.surfaceContainerHighest, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SubscriptionLogoWidget(
          name: subscription.name,
          category: subscription.category,
          size: 48,
          borderRadius: 14,
          isActive: true,
        ),
        title: Text(
          subscription.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${subscription.currency} ${subscription.cost.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: urgencyColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            _urgencyLabel(days),
            style: TextStyle(
              color: urgencyColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
