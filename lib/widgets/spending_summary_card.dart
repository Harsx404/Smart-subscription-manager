import 'package:flutter/material.dart';

class SpendingSummaryCard extends StatelessWidget {
  final double monthly;
  final double yearly;
  final String currency;
  final int count;

  const SpendingSummaryCard({
    super.key,
    required this.monthly,
    required this.yearly,
    required this.currency,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Spending',
                style: TextStyle(
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count active',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currency ${monthly.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.onPrimary.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(
                label: 'Yearly Total',
                value: '$currency ${yearly.toStringAsFixed(2)}',
                onPrimary: colorScheme.onPrimary,
              ),
              const Spacer(),
              _Stat(
                label: 'Per Day',
                value: '$currency ${(monthly / 30).toStringAsFixed(2)}',
                onPrimary: colorScheme.onPrimary,
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color onPrimary;
  final bool alignEnd;

  const _Stat({
    required this.label,
    required this.value,
    required this.onPrimary,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: onPrimary.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
