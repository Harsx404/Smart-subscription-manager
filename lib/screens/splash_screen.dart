import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Wait for animation to mostly finish
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    await context.read<SubscriptionProvider>().loadSubscriptions();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    cs.surface,
                    cs.surfaceContainerHighest,
                  ]
                : [
                    cs.primary,
                    const Color(0xFF6366F1), // slightly lighter indigo
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ).animate()
              .scale(duration: 800.ms, curve: Curves.easeOutBack, begin: const Offset(0.5, 0.5))
              .fadeIn(duration: 800.ms)
              .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
            
            const SizedBox(height: 32),
            
            Text(
              'Smart Subscription',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ).animate()
              .slideY(begin: 0.5, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutQuint)
              .fadeIn(duration: 600.ms, delay: 300.ms),
            
            Text(
              'Manager',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: (isDark ? Colors.white : Colors.white).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                  ),
            ).animate()
              .slideY(begin: 0.5, duration: 600.ms, delay: 400.ms, curve: Curves.easeOutQuint)
              .fadeIn(duration: 600.ms, delay: 400.ms),
              
            const SizedBox(height: 48),
            
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  (isDark ? cs.primary : Colors.white).withValues(alpha: 0.8)
                ),
              ),
            ).animate()
              .fadeIn(delay: 800.ms, duration: 400.ms)
              .scale(delay: 800.ms, begin: const Offset(0.5, 0.5)),
          ],
        ),
      ),
    );
  }
}
