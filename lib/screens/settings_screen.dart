import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Settings')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionHeader('Notifications'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Billing Reminders'),
                      subtitle: const Text(
                          'Get notified 3 days, 1 day, and on billing date'),
                      value: true,
                      onChanged: (v) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader('Data Management'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete_sweep_outlined),
                      title: const Text('Clear All Subscriptions'),
                      subtitle: const Text('Permanently delete all data'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showClearDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader('About'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.subscriptions_rounded,
                            color: cs.onPrimaryContainer, size: 20),
                      ),
                      title: const Text('Smart Subscription Manager'),
                      subtitle: const Text('Version 1.0.0'),
                    ),
                    const Divider(height: 0, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.flutter_dash),
                      title: const Text('Built with Flutter'),
                      subtitle: const Text('Material Design 3'),
                    ),
                    const Divider(height: 0, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy'),
                      subtitle: const Text(
                          'All data is stored locally on your device'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Made with ❤️ using Flutter',
                  style: TextStyle(color: cs.outline, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error, size: 36),
        title: const Text('Clear All Data'),
        content: const Text(
            'This will permanently delete all your subscriptions and cannot be undone.'),
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
            onPressed: () async {
              final provider = context.read<SubscriptionProvider>();
              final ids =
                  provider.subscriptions.map((s) => s.id).toList();
              for (final id in ids) {
                await provider.deleteSubscription(id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
