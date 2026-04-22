import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    await context.read<SubscriptionProvider>().loadSubscriptions();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.subscriptions_rounded,
                    size: 80,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Smart Subscription',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Manager',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w300,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track · Manage · Save',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
