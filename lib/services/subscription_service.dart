import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../domain/repositories/habit_repository.dart';

class PromoActivationResult {
  final bool success;
  final String message;

  const PromoActivationResult({
    required this.success,
    required this.message,
  });
}

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  Map<String, dynamic>? _promoKeysCache;

  Future<Map<String, dynamic>> _loadPromoKeys() async {
    if (_promoKeysCache != null) {
      return _promoKeysCache!;
    }
    final raw = await rootBundle.loadString('promo_keys.json');
    _promoKeysCache = jsonDecode(raw) as Map<String, dynamic>;
    return _promoKeysCache!;
  }

  Future<bool> isSubscriptionActive() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAtRaw = prefs.getString(AppConstants.keySubscriptionUntil);
    if (expiresAtRaw != null && expiresAtRaw.isNotEmpty) {
      final expiresAt = DateTime.tryParse(expiresAtRaw);
      if (expiresAt != null) {
        final active = expiresAt.isAfter(DateTime.now());
        await prefs.setBool(AppConstants.keySubscriptionActive, active);
        return active;
      }
    }
    return prefs.getBool(AppConstants.keySubscriptionActive) ?? false;
  }

  Future<void> setSubscriptionActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keySubscriptionActive, active);
    if (!active) {
      await prefs.remove(AppConstants.keySubscriptionPlan);
      await prefs.remove(AppConstants.keySubscriptionUntil);
    }
  }

  Future<String?> getActivePlan() async {
    final active = await isSubscriptionActive();
    if (!active) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keySubscriptionPlan);
  }

  Future<DateTime?> getActiveUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.keySubscriptionUntil);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<PromoActivationResult> activatePromoCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      return const PromoActivationResult(
        success: false,
        message: 'Введите промокод',
      );
    }

    final promoKeys = await _loadPromoKeys();
    final prefs = await SharedPreferences.getInstance();
    final redeemed =
        prefs.getStringList(AppConstants.keyRedeemedPromoCodes) ?? <String>[];

    if (redeemed.contains(normalized)) {
      return const PromoActivationResult(
        success: false,
        message: 'Этот ключ уже использован на данном устройстве',
      );
    }

    final promo = promoKeys[normalized];
    if (promo is! Map<String, dynamic>) {
      return const PromoActivationResult(
        success: false,
        message: 'Промокод не найден',
      );
    }

    final plan = promo['plan'] as String? ?? 'Базовая';
    final days = promo['days'] as int? ?? 7;
    final expiresAt = DateTime.now().add(Duration(days: days));

    await prefs.setBool(AppConstants.keySubscriptionActive, true);
    await prefs.setString(AppConstants.keySubscriptionPlan, plan);
    await prefs.setString(
      AppConstants.keySubscriptionUntil,
      expiresAt.toIso8601String(),
    );
    await prefs.setStringList(
      AppConstants.keyRedeemedPromoCodes,
      [...redeemed, normalized],
    );

    return PromoActivationResult(
      success: true,
      message: 'Промокод активирован: $plan на $days дней',
    );
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


