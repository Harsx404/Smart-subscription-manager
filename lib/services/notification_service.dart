import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _remindersPerSubscription = 3;
  static const _maxAndroidNotificationId = 0x7fffffff;
  static const _maxNotificationGroup =
      (_maxAndroidNotificationId - (_remindersPerSubscription - 1)) ~/
      _remindersPerSubscription;

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static const _channel = AndroidNotificationDetails(
    'subscription_reminders',
    'Subscription Reminders',
    channelDescription: 'Reminders for upcoming subscription billing dates',
    importance: Importance.high,
    priority: Priority.high,
  );

  static Future<void> scheduleSubscriptionReminders(Subscription sub) async {
    try {
      await cancelSubscriptionReminders(sub.id);
      if (!sub.isActive) return;

      final baseId = _baseNotificationId(sub.id);
      final daysUntil = sub.daysUntilBilling;

      if (daysUntil >= 3) {
        await _schedule(
          id: baseId,
          title: 'Upcoming Subscription',
          body: 'Your ${sub.name} subscription renews in 3 days.',
          date: sub.nextBillingDate.subtract(const Duration(days: 3)),
        );
      }

      if (daysUntil >= 1) {
        await _schedule(
          id: baseId + 1,
          title: 'Subscription Due Tomorrow',
          body:
              '${sub.name} will charge ${sub.currency} ${sub.cost.toStringAsFixed(2)} tomorrow.',
          date: sub.nextBillingDate.subtract(const Duration(days: 1)),
        );
      }

      if (daysUntil >= 0) {
        await _schedule(
          id: baseId + 2,
          title: 'Billing Due Today',
          body: '${sub.name} billing is due today.',
          date: sub.nextBillingDate,
        );
      }
    } catch (_) {
      // Reminder scheduling should never block saving the subscription.
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
    final base = _baseNotificationId(subId);
    for (var offset = 0; offset < _remindersPerSubscription; offset++) {
      try {
        await _plugin.cancel(base + offset);
      } catch (_) {
        // Ignore cancellation failures so edits and saves can proceed.
      }
    }
  }

  static int _baseNotificationId(String subscriptionId) {
    var hash = 0;
    for (final codeUnit in subscriptionId.codeUnits) {
      hash = ((hash * 31) + codeUnit) & _maxAndroidNotificationId;
    }
    return (hash % (_maxNotificationGroup + 1)) * _remindersPerSubscription;
  }
}
