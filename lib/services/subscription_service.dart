import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../domain/repositories/habit_repository.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  Future<bool> isSubscriptionActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keySubscriptionActive) ?? false;
  }

  Future<void> setSubscriptionActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keySubscriptionActive, active);
  }

  Future<bool> canCreateHabit(HabitRepository repository) async {
    final isActive = await isSubscriptionActive();
    if (isActive) return true; // Unlimited for premium

    final count = await repository.getHabitCount();
    return count < AppConstants.freeHabitLimit;
  }

  Future<int> getRemainingFreeHabits(HabitRepository repository) async {
    final isActive = await isSubscriptionActive();
    if (isActive) return -1; // Unlimited

    final count = await repository.getHabitCount();
    final remaining = AppConstants.freeHabitLimit - count;
    return remaining > 0 ? remaining : 0;
  }

  // Placeholder for future RuStore integration
  Future<void> purchaseSubscription() async {
    // TODO: Integrate with RuStore
    // For now, just set as active for testing
    await setSubscriptionActive(true);
  }

  Future<void> restoreSubscription() async {
    // TODO: Check RuStore for existing subscription
    // For now, just check local storage
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(AppConstants.keySubscriptionActive) ?? false;
    if (!isActive) {
      // In real implementation, check RuStore API
    }
  }
}


