import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/subscription.dart';
import 'providers/subscription_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_subscription_screen.dart';
import 'screens/edit_subscription_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Smart Subscription Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/add') {
          return MaterialPageRoute(
              builder: (_) => const AddSubscriptionScreen());
        }
        if (settings.name == '/edit') {
          final sub = settings.arguments as Subscription;
          return MaterialPageRoute(
              builder: (_) => EditSubscriptionScreen(subscription: sub));
        }
        return null;
      },
    );
  }
}

