import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int? _touchedPieIndex;

  static const _chartColors = [
    Color(0xFF6750A4),
    Color(0xFF7D5260),
    Color(0xFF006874),
    Color(0xFFB25E02),
    Color(0xFF006E2C),
    Color(0xFFC63B3B),
    Color(0xFF5059A1),
    Color(0xFF8B5E3C),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final cs = Theme.of(context).colorScheme;
    final categorySpending = provider.categorySpending;
    final categories = categorySpending.keys.toList();
    final values = categorySpending.values.toList();
    final total = values.fold(0.0, (a, b) => a + b);
    final currency = provider.primaryCurrency;

    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Analytics')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Summary row
              Row(
                children: [
                  _SummaryTile(
                    title: 'Monthly',
                    value: '$currency ${provider.totalMonthlyCost.toStringAsFixed(2)}',
                    icon: Icons.calendar_month_outlined,
                    color: cs.primaryContainer,
                    onColor: cs.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  _SummaryTile(
                    title: 'Yearly',
                    value: '$currency ${provider.totalYearlyCost.toStringAsFixed(2)}',
                    icon: Icons.calendar_today_outlined,
                    color: cs.secondaryContainer,
                    onColor: cs.onSecondaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SummaryTile(
                    title: 'Active',
                    value: '${provider.activeSubscriptions.length} subs',
                    icon: Icons.check_circle_outline,
                    color: cs.tertiaryContainer,
                    onColor: cs.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  _SummaryTile(
                    title: 'Daily Cost',
                    value: '$currency ${(provider.totalMonthlyCost / 30).toStringAsFixed(2)}',
                    icon: Icons.today_outlined,
                    color: cs.surfaceContainerHighest,
                    onColor: cs.onSurface,
                  ),
                ],
              ),

              if (provider.activeSubscriptions.isEmpty) ...[
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.analytics_outlined,
                          size: 72, color: cs.outlineVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No data yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add subscriptions to see\nspending analytics',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),

                // Pie chart card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spending by Category',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      _touchedPieIndex = null;
                                    } else {
                                      _touchedPieIndex = response
                                          .touchedSection!
                                          .touchedSectionIndex;
                                    }
                                  });
                                },
                              ),
                              sectionsSpace: 3,
                              centerSpaceRadius: 55,
                              sections: List.generate(categories.length, (i) {
                                final isTouched = i == _touchedPieIndex;
                                final pct = total > 0
                                    ? values[i] / total * 100
                                    : 0.0;
                                return PieChartSectionData(
                                  color: _chartColors[i % _chartColors.length],
                                  value: values[i],
                                  title: '${pct.toStringAsFixed(1)}%',
                                  radius: isTouched ? 70 : 58,
                                  titleStyle: TextStyle(
                                    fontSize: isTouched ? 13 : 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: List.generate(
                            categories.length,
                            (i) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color:
                                        _chartColors[i % _chartColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  categories[i],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bar chart card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Cost per Category',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: values.isEmpty
                                  ? 100
                                  : values.reduce(
                                          (a, b) => a > b ? a : b) *
                                      1.4,
                              barGroups:
                                  List.generate(categories.length, (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: values[i],
                                      color: _chartColors[
                                          i % _chartColors.length],
                                      width: 22,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(6)),
                                    ),
                                  ],
                                );
                              }),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      final idx = v.toInt();
                                      if (idx >= 0 &&
                                          idx < categories.length) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Text(
                                            AppConstants.categoryIcons[
                                                    categories[idx]] ??
                                                '📦',
                                            style: const TextStyle(
                                                fontSize: 16),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 42,
                                    getTitlesWidget: (v, _) => Text(
                                      v.toInt().toString(),
                                      style: TextStyle(
                                          fontSize: 10, color: cs.outline),
                                    ),
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (v) => FlLine(
                                  color: cs.outlineVariant.withValues(alpha: 0.5),
                                  strokeWidth: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Smart insights card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Smart Insights',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ..._buildInsights(provider, cs, currency),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInsights(
      SubscriptionProvider provider, ColorScheme cs, String currency) {
    final insights = <Widget>[];
    final active = provider.activeSubscriptions;
    final spending = provider.categorySpending;

    if (active.isNotEmpty) {
      insights.add(_InsightItem(
        icon: '📊',
        text: 'You have ${active.length} active subscription(s) costing'
            ' $currency ${provider.totalMonthlyCost.toStringAsFixed(2)}/month.',
        bgColor: cs.primaryContainer,
      ));
    }

    final entertainment =
        active.where((s) => s.category == 'Entertainment').length;
    if (entertainment >= 2) {
      insights.add(_InsightItem(
        icon: '🎬',
        text: 'You have $entertainment entertainment subscriptions. '
            'Consider if you need all of them.',
        bgColor: cs.secondaryContainer,
      ));
    }

    if (spending.isNotEmpty) {
      final top = spending.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(_InsightItem(
        icon: '💰',
        text: '${top.key} is your biggest expense at'
            ' $currency ${top.value.toStringAsFixed(2)}/month.',
        bgColor: cs.tertiaryContainer,
      ));
    }

    final yearly =
        active.where((s) => s.billingCycle == BillingCycle.yearly).length;
    if (yearly > 0) {
      insights.add(_InsightItem(
        icon: '📅',
        text: '$yearly subscription(s) billed yearly — '
            'make sure you\'re still using them!',
        bgColor: cs.surfaceContainerHighest,
      ));
    }

    final cancelled = provider.cancelledSubscriptions;
    if (cancelled.isNotEmpty) {
      insights.add(_InsightItem(
        icon: '✅',
        text: 'You\'ve cancelled ${cancelled.length} subscription(s). '
            'Great job managing your spending!',
        bgColor: cs.primaryContainer,
      ));
    }

    return insights;
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color onColor;

  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onColor, size: 20),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    color: onColor.withValues(alpha: 0.75), fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  color: onColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final String icon;
  final String text;
  final Color bgColor;

  const _InsightItem({
    required this.icon,
    required this.text,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
