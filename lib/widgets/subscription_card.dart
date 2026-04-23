import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import 'subscription_logo.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = subscription.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openEdit(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SubscriptionLogoWidget(
                  name: subscription.name,
                  category: subscription.category,
                  size: 52,
                  borderRadius: 16,
                  isActive: isActive,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subscription.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isActive ? colorScheme.onSurface : colorScheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isActive)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Cancelled',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subscription.category,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (isActive && subscription.daysUntilBilling <= 7 && subscription.daysUntilBilling >= 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subscription.daysUntilBilling == 0
                                ? 'Billing today!'
                                : 'Billing in ${subscription.daysUntilBilling} day(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: subscription.daysUntilBilling <= 1
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${subscription.currency} ${subscription.cost.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: isActive ? colorScheme.primary : colorScheme.outline,
                      ),
                    ),
                    Text(
                      '/${subscription.billingCycle.name}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) => _handleAction(context, value),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            isActive
                                ? Icons.cancel_outlined
                                : Icons.check_circle_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(isActive ? 'Cancel' : 'Reactivate'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.pushNamed(context, '/edit', arguments: subscription);
  }

  void _handleAction(BuildContext context, String action) {
    final provider = context.read<SubscriptionProvider>();
    if (action == 'edit') {
      _openEdit(context);
    } else if (action == 'toggle') {
      provider.toggleSubscriptionStatus(subscription.id);
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Subscription'),
          content: Text(
              'Delete "${subscription.name}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                minimumSize: const Size(80, 40),
              ),
              onPressed: () {
                provider.deleteSubscription(subscription.id);
                Navigator.pop(ctx);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}
