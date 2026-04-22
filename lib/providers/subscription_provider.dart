import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final _storage = StorageService();
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;

  List<Subscription> get activeSubscriptions =>
      _subscriptions.where((s) => s.isActive).toList();

  List<Subscription> get cancelledSubscriptions =>
      _subscriptions.where((s) => !s.isActive).toList();

  List<Subscription> get upcomingPayments {
    final list = activeSubscriptions
        .where((s) => s.daysUntilBilling >= 0 && s.daysUntilBilling <= 30)
        .toList()
      ..sort((a, b) => a.daysUntilBilling.compareTo(b.daysUntilBilling));
    return list;
  }

  double get totalMonthlyCost =>
      activeSubscriptions.fold(0.0, (sum, s) => sum + s.monthlyCost);

  double get totalYearlyCost =>
      activeSubscriptions.fold(0.0, (sum, s) => sum + s.yearlyCost);

  Map<String, double> get categorySpending {
    final map = <String, double>{};
    for (final sub in activeSubscriptions) {
      map[sub.category] = (map[sub.category] ?? 0) + sub.monthlyCost;
    }
    return map;
  }

  String get primaryCurrency =>
      activeSubscriptions.isNotEmpty ? activeSubscriptions.first.currency : 'INR';

  Future<void> loadSubscriptions() async {
    _isLoading = true;
    notifyListeners();
    _subscriptions = await _storage.loadSubscriptions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSubscription(Subscription sub) async {
    _subscriptions.add(sub);
    await _storage.saveSubscriptions(_subscriptions);
    await NotificationService.scheduleSubscriptionReminders(sub);
    notifyListeners();
  }

  Future<void> updateSubscription(Subscription updated) async {
    final index = _subscriptions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _subscriptions[index] = updated;
      await _storage.saveSubscriptions(_subscriptions);
      await NotificationService.scheduleSubscriptionReminders(updated);
      notifyListeners();
    }
  }

  Future<void> deleteSubscription(String id) async {
    await NotificationService.cancelSubscriptionReminders(id);
    _subscriptions.removeWhere((s) => s.id == id);
    await _storage.saveSubscriptions(_subscriptions);
    notifyListeners();
  }

  Future<void> toggleSubscriptionStatus(String id) async {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updated = _subscriptions[index].copyWith(
        isActive: !_subscriptions[index].isActive,
      );
      _subscriptions[index] = updated;
      await _storage.saveSubscriptions(_subscriptions);
      if (updated.isActive) {
        await NotificationService.scheduleSubscriptionReminders(updated);
      } else {
        await NotificationService.cancelSubscriptionReminders(id);
      }
      notifyListeners();
    }
  }
}
