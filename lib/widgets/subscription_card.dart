import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = subscription.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openEdit(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    AppConstants.categoryIcons[subscription.category] ?? '📦',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isActive ? null : colorScheme.outline,
                            ),
                          ),
                        ),
                        if (!isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
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
                        fontSize: 12,
                        color: colorScheme.outline,
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
                            fontSize: 11,
                            color: subscription.daysUntilBilling <= 1
                                ? Colors.red
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isActive ? colorScheme.primary : colorScheme.outline,
                    ),
                  ),
                  Text(
                    '/${subscription.billingCycle.name}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleAction(context, value),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
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
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(isActive ? 'Cancel' : 'Reactivate'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
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
