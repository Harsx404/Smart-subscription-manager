import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static const _channel = AndroidNotificationDetails(
    'subscription_reminders',
    'Subscription Reminders',
    channelDescription: 'Reminders for upcoming subscription billing dates',
    importance: Importance.high,
    priority: Priority.high,
  );

  static Future<void> scheduleSubscriptionReminders(
      Subscription sub) async {
    await cancelSubscriptionReminders(sub.id);
    if (!sub.isActive) return;

    final daysUntil = sub.daysUntilBilling;

    if (daysUntil >= 3) {
      await _schedule(
        id: sub.id.hashCode.abs() * 3,
        title: 'Upcoming Subscription',
        body: 'Your ${sub.name} subscription renews in 3 days.',
        date: sub.nextBillingDate.subtract(const Duration(days: 3)),
      );
    }

    if (daysUntil >= 1) {
      await _schedule(
        id: sub.id.hashCode.abs() * 3 + 1,
        title: 'Subscription Due Tomorrow',
        body:
            '${sub.name} will charge ${sub.currency} ${sub.cost.toStringAsFixed(2)} tomorrow.',
        date: sub.nextBillingDate.subtract(const Duration(days: 1)),
      );
    }

    if (daysUntil >= 0) {
      await _schedule(
        id: sub.id.hashCode.abs() * 3 + 2,
        title: 'Billing Due Today',
        body: '${sub.name} billing is due today.',
        date: sub.nextBillingDate,
      );
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    if (date.isBefore(DateTime.now())) return;
    try {
      final tzDate = tz.TZDateTime.from(date, tz.local);
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Scheduling may fail if exact alarm permission is denied; ignore silently
    }
  }

  static Future<void> cancelSubscriptionReminders(String subId) async {
    final base = subId.hashCode.abs() * 3;
    await _plugin.cancel(base);
    await _plugin.cancel(base + 1);
    await _plugin.cancel(base + 2);
  }
}
