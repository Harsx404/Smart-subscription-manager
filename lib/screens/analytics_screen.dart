import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  // Modern Chart Colors
  static const _chartColors = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF43F5E), // Rose
    Color(0xFF84CC16), // Lime
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final categorySpending = provider.categorySpending;
    final categories = categorySpending.keys.toList();
    final values = categorySpending.values.toList();
    final total = values.fold(0.0, (a, b) => a + b);
    final currency = provider.primaryCurrency;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text(
            'Analytics',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
          pinned: true,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Summary row
              Row(
                children: [
                  _SummaryTile(
                    title: 'Monthly Total',
                    value: '$currency ${provider.totalMonthlyCost.toStringAsFixed(2)}',
                    icon: Icons.calendar_month_outlined,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    iconColor: const Color(0xFF4F46E5),
                  ),
                  const SizedBox(width: 12),
                  _SummaryTile(
                    title: 'Yearly Projection',
                    value: '$currency ${provider.totalYearlyCost.toStringAsFixed(2)}',
                    icon: Icons.auto_graph_outlined,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    iconColor: const Color(0xFF10B981),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SummaryTile(
                    title: 'Active Subs',
                    value: '${provider.activeSubscriptions.length}',
                    icon: Icons.check_circle_outline,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 12),
                  _SummaryTile(
                    title: 'Daily Average',
                    value: '$currency ${(provider.totalMonthlyCost / 30).toStringAsFixed(2)}',
                    icon: Icons.today_outlined,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    iconColor: const Color(0xFFEC4899),
                  ),
                ],
              ),

              if (provider.activeSubscriptions.isEmpty) ...[
                const SizedBox(height: 64),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.analytics_outlined,
                            size: 64, color: cs.primary.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No data yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add subscriptions to see\nyour spending insights',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.outline, height: 1.5),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad),
                ),
              ] else ...[
                const SizedBox(height: 24),

                // Pie chart card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cs.surfaceContainerHighest, width: 1),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending by Category',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
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
                                sectionsSpace: 4,
                                centerSpaceRadius: 65,
                                sections: List.generate(categories.length, (i) {
                                  final isTouched = i == _touchedPieIndex;
                                  final pct = total > 0
                                      ? values[i] / total * 100
                                      : 0.0;
                                  return PieChartSectionData(
                                    color: _chartColors[i % _chartColors.length],
                                    value: values[i],
                                    title: '${pct.toStringAsFixed(0)}%',
                                    radius: isTouched ? 65 : 55,
                                    titleStyle: TextStyle(
                                      fontSize: isTouched ? 14 : 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    badgeWidget: isTouched
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              categories[i],
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        : null,
                                    badgePositionPercentageOffset: 1.2,
                                  );
                                }),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(fontSize: 12, color: cs.outline, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '$currency${total.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: List.generate(
                          categories.length,
                          (i) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _chartColors[i % _chartColors.length],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                categories[i],
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bar chart card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cs.surfaceContainerHighest, width: 1),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Cost per Category',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 240, // Increased height
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: values.isEmpty
                                ? 100
                                : values.reduce((a, b) => a > b ? a : b) * 1.3, // Increased overhead
                            barGroups: List.generate(categories.length, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: values[i],
                                    gradient: LinearGradient(
                                      colors: [
                                        _chartColors[i % _chartColors.length].withValues(alpha: 0.6),
                                        _chartColors[i % _chartColors.length],
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    width: 24,
                                    borderRadius: BorderRadius.circular(6),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: values.reduce((a, b) => a > b ? a : b) * 1.3,
                                      color: isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFFF1F5F9),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36, // Added reservedSize
                                  getTitlesWidget: (v, _) {
                                    final idx = v.toInt();
                                    if (idx >= 0 && idx < categories.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          AppConstants.categoryIcons[categories[idx]] ?? '📦',
                                          style: const TextStyle(fontSize: 18),
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
                                  reservedSize: 40,
                                  getTitlesWidget: (v, _) {
                                    if (v == 0) return const SizedBox();
                                    return Text(
                                      v.toInt().toString(),
                                      style: TextStyle(fontSize: 10, color: cs.outline),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                            ),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => isDark ? const Color(0xFF1E293B) : Colors.white,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '$currency${rod.toY.toStringAsFixed(0)}',
                                    TextStyle(
                                      color: cs.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Smart insights card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cs.surfaceContainerHighest, width: 1),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: const Color(0xFFF59E0B), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Smart Insights',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ..._buildInsights(provider, cs, currency, isDark),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 88),
            ].animate(interval: 80.ms).fadeIn(duration: 500.ms, curve: Curves.easeOutQuad).slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutQuad)),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInsights(
      SubscriptionProvider provider, ColorScheme cs, String currency, bool isDark) {
    final insights = <Widget>[];
    final active = provider.activeSubscriptions;
    final spending = provider.categorySpending;

    if (active.isNotEmpty) {
      insights.add(_InsightItem(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF4F46E5), // Indigo
        title: 'Total Spending',
        text: 'You have ${active.length} active subscription(s) costing'
            ' $currency ${provider.totalMonthlyCost.toStringAsFixed(2)}/month.',
      ));
    }

    final entertainment =
        active.where((s) => s.category == 'Entertainment').length;
    if (entertainment >= 2) {
      insights.add(_InsightItem(
        icon: Icons.movie_filter_outlined,
        iconColor: const Color(0xFFF59E0B), // Amber
        title: 'Entertainment Heavy',
        text: 'You have $entertainment entertainment subscriptions. '
            'Consider if you need all of them.',
      ));
    }

    if (spending.isNotEmpty) {
      final top = spending.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(_InsightItem(
        icon: Icons.trending_up,
        iconColor: const Color(0xFFEF4444), // Red
        title: 'Top Category',
        text: '${top.key} is your biggest expense at'
            ' $currency ${top.value.toStringAsFixed(2)}/month.',
      ));
    }

    final yearly =
        active.where((s) => s.billingCycle == BillingCycle.yearly).length;
    if (yearly > 0) {
      insights.add(_InsightItem(
        icon: Icons.calendar_today_outlined,
        iconColor: const Color(0xFF10B981), // Emerald
        title: 'Yearly Commitments',
        text: '$yearly subscription(s) billed yearly — '
            'make sure you\'re still actively using them!',
      ));
    }

    final cancelled = provider.cancelledSubscriptions;
    if (cancelled.isNotEmpty) {
      insights.add(_InsightItem(
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF8B5CF6), // Violet
        title: 'Money Saved',
        text: 'You\'ve cancelled ${cancelled.length} subscription(s). '
            'Great job managing your spending and saving money!',
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
  final Color iconColor;

  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;

  const _InsightItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.surfaceContainerHighest.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
