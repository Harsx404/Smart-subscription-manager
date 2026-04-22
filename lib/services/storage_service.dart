import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

class StorageService {
  static const _key = 'subscriptions_v1';

  Future<List<Subscription>> loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    final result = <Subscription>[];
    for (final json in jsonList) {
      try {
        result.add(Subscription.fromJson(json));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    return result;
  }

  Future<void> saveSubscriptions(List<Subscription> subscriptions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = subscriptions.map((s) => s.toJson()).toList();
    await prefs.setStringList(_key, jsonList);
  }
}
