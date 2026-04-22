import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/subscription_card.dart';
import '../widgets/upcoming_payment_card.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Analytics',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _HomeTab(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _destinations,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final upcoming = provider.upcomingPayments;
    final active = provider.activeSubscriptions;
    final allSubs = provider.subscriptions;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('My Subscriptions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add subscription',
              onPressed: () => Navigator.pushNamed(context, '/add'),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SpendingSummaryCard(
                monthly: provider.totalMonthlyCost,
                yearly: provider.totalYearlyCost,
                currency: provider.primaryCurrency,
                count: active.length,
              ),
              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SectionTitle(
                  title: 'Upcoming Payments',
                  subtitle: '${upcoming.length} in next 30 days',
                ),
                const SizedBox(height: 10),
                ...upcoming
                    .take(5)
                    .map((s) => UpcomingPaymentCard(subscription: s)),
              ],
              const SizedBox(height: 24),
              _SectionTitle(
                title: 'All Subscriptions',
                subtitle: '${active.length} active',
              ),
              const SizedBox(height: 10),
              if (allSubs.isEmpty)
                const _EmptyState()
              else
                ...allSubs.map((s) => SubscriptionCard(subscription: s)),
              const SizedBox(height: 88),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No subscriptions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your\nfirst subscription',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
